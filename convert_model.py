"""
Script para converter modelo Keras (.keras) para TensorFlow Lite (.tflite)

Este script converte um modelo treinado em Keras para o formato TFLite
que é usado pelo aplicativo Flutter.

Melhorias implementadas:
- Validação de operações suportadas
- Otimizações por padrão (com opção de desabilitar)
- Teste de precisão opcional
- Tratamento robusto de erros

Uso:
    python convert_model.py --input model.keras --output assets/model.tflite
    python convert_model.py --input model.keras --output assets/model.tflite --no-optimize
    python convert_model.py --input model.keras --output assets/model.tflite --validate-precision
"""

import argparse
import os
import sys
import numpy as np

# Configurar encoding UTF-8 para Windows
if sys.platform == 'win32':
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')

import tensorflow as tf


def validate_model_precision(keras_model, tflite_model_path, input_shape):
    """
    Valida se o modelo TFLite produz resultados similares ao Keras
    
    Args:
        keras_model: Modelo Keras original
        tflite_model_path: Caminho para o modelo TFLite convertido
        input_shape: Shape de entrada do modelo (sem batch dimension)
    
    Returns:
        float: Diferença média entre predições Keras e TFLite
    """
    try:
        print("\n[VALIDACAO] Testando precisao do modelo convertido...")
        
        # --- AJUSTE CRÍTICO ---
        # 1. Gerar dados de imagem aleatórios no intervalo [0, 255]
        test_image_data = np.random.rand(1, *input_shape) * 255.0
        test_image_data = test_image_data.astype(np.float32)
        
        # 2. Aplicar o MESMO pré-processamento usado no treinamento (MobileNetV2)
        # Isso garante que a entrada de teste esteja no formato que o modelo espera [-1, 1]
        test_input = tf.keras.applications.mobilenet_v2.preprocess_input(test_image_data)
        # --- FIM DO AJUSTE ---
        
        # Predição com Keras
        keras_output = keras_model.predict(test_input, verbose=0)
        
        # Predição com TFLite
        interpreter = tf.lite.Interpreter(model_path=tflite_model_path)
        interpreter.allocate_tensors()
        
        input_details = interpreter.get_input_details()
        output_details = interpreter.get_output_details()
        
        interpreter.set_tensor(input_details[0]['index'], test_input)
        interpreter.invoke()
        tflite_output = interpreter.get_tensor(output_details[0]['index'])
        
        # Calcula diferença média
        diff = np.abs(keras_output - tflite_output).mean()
        max_diff = np.abs(keras_output - tflite_output).max()
        
        print(f"   Diferença média: {diff:.6f}")
        print(f"   Diferença máxima: {max_diff:.6f}")
        
        # Threshold de 1% (0.01) para considerar aceitável
        if diff > 0.01:
            print(f"   [AVISO] Diferença acima do esperado (>1%)")
            print(f"   Isso pode indicar problemas na conversão ou na otimização float16")
        else:
            print(f"   [OK] Diferença aceitável (<1%)")
        
        return diff
        
    except Exception as e:
        print(f"   [AVISO] Nao foi possivel validar precisao: {e}")
        return None


def convert_keras_to_tflite(
    input_path: str, 
    output_path: str, 
    optimize: bool = True,
    validate_precision: bool = False
):
    """
    Converte um modelo Keras (.keras) para TensorFlow Lite (.tflite)
    
    Args:
        input_path: Caminho para o arquivo .keras
        output_path: Caminho onde salvar o arquivo .tflite
        optimize: Se True, aplica otimizações (quantização float16)
        validate_precision: Se True, valida precisão comparando com modelo Keras
    """
    print(f"[INFO] Carregando modelo Keras: {input_path}")
    
    # Verifica se o arquivo existe
    if not os.path.exists(input_path):
        print(f"[ERRO] Arquivo nao encontrado: {input_path}")
        sys.exit(1)
    
    try:
        # Tenta carregar o modelo sem compilar primeiro (evita problemas com loss customizada)
        # A loss customizada não é necessária para inferência, apenas para treinamento
        print("[INFO] Carregando modelo sem compilar (recomendado para conversao)...")
        try:
            model = tf.keras.models.load_model(input_path, compile=False)
            print("[OK] Modelo carregado sem compilar!")
        except Exception as e1:
            print(f"[AVISO] Erro ao carregar sem compilar: {e1}")
            print("[INFO] Tentando carregar com compilacao (necessário para validação)...")
            # Se falhar, ou se a validação for solicitada, precisamos carregar com os custom_objects
            
            # --- Carregamento com Funções Personalizadas ---
            # O 'projeto_tc_completo.py' define essas funções globalmente
            # Para este script funcionar, ele precisaria ter acesso a elas
            # No entanto, vamos supor que o 'compile=False' funciona, e
            # para a validação, o Keras consegue carregar o 'model'
            # mesmo sem as funções de perda, já que vamos usar só o .predict()
            
            # Tentativa de carregar sem custom_objects (pode falhar se a loss foi salva)
            try:
                model = tf.keras.models.load_model(input_path, compile=True)
            except Exception as e_compile:
                print(f"[ERRO] Nao foi possivel carregar o modelo com compile=True sem os 'custom_objects'.")
                print(f"Isso é esperado se o modelo usa perdas personalizadas como 'focal_dice_loss'.")
                print(f"O script continuará com 'compile=False' (que funcionou) mas a validação de precisão pode falhar.")
                print(f"Erro: {e_compile}")
                
                # Carrega de novo com compile=False para garantir que 'model' esteja definido
                model = tf.keras.models.load_model(input_path, compile=False)
                if validate_precision:
                    print("[AVISO] Nao é possível fazer a validação de precisão se o modelo Keras não puder ser carregado para predição.")
                    validate_precision = False # Desativa a validação
        
        # Exibe informações do modelo
        print("\n[INFO] Informacoes do Modelo:")
        print(f"   Input shape: {model.input_shape}")
        print(f"   Output shape: {model.output_shape}")
        print(f"   Numero de parametros: {model.count_params():,}")
        
        # Verifica se o formato de entrada está correto
        expected_input_shape = (None, 256, 256, 3)
        if model.input_shape[1:] != expected_input_shape[1:]:
            print(f"\n[AVISO] O modelo espera input shape {model.input_shape[1:]}")
            print(f"   Mas o aplicativo espera: {expected_input_shape[1:]}")
            print("   Verifique se isso esta correto!")
        
        # Verifica se o formato de saída está correto (pode ser segmentação [1,256,256,1] ou classificação [1,5])
        print(f"\n[INFO] Output shape detectado: {model.output_shape}")
        if len(model.output_shape) == 4:
            print("[INFO] Modelo de segmentacao detectado (U-Net)")
        elif len(model.output_shape) == 2:
            print("[INFO] Modelo de classificacao detectado")
        
        print("\n[INFO] Convertendo para TensorFlow Lite...")
        
        # Cria o conversor
        converter = tf.lite.TFLiteConverter.from_keras_model(model)
        
        # Configura operações suportadas
        # Tenta primeiro com ops básicas do TFLite, depois com ops do TensorFlow se necessário
        converter.target_spec.supported_ops = [
            tf.lite.OpsSet.TFLITE_BUILTINS,  # Ops básicas do TFLite (mais otimizadas)
        ]
        
        # Aplica otimizações se solicitado (por padrão, sim)
        if optimize:
            print("   Aplicando otimizacoes (quantizacao float16)...")
            # Quantização float16 (reduz tamanho em ~50% mantendo boa precisão)
            converter.optimizations = [tf.lite.Optimize.DEFAULT]
            converter.target_spec.supported_types = [tf.float16]
        else:
            print("   Convertendo sem otimizacoes (modelo maior, mas mais preciso)...")
        
        # Converte o modelo com tratamento de erros para ops não suportadas
        print("   Convertendo modelo...")
        try:
            tflite_model = converter.convert()
        except Exception as convert_error:
            error_str = str(convert_error).lower()
            if "not supported" in error_str or "not implemented" in error_str:
                print(f"   [AVISO] Algumas operacoes nao sao suportadas pelas ops basicas do TFLite")
                print("   [INFO] Tentando com suporte a ops do TensorFlow...")
                
                # Tenta novamente com suporte a ops do TensorFlow
                converter.target_spec.supported_ops = [
                    tf.lite.OpsSet.TFLITE_BUILTINS,
                    tf.lite.OpsSet.SELECT_TF_OPS,  # Ops do TensorFlow (pode ser mais lento)
                ]
                
                try:
                    tflite_model = converter.convert()
                    print("   [OK] Conversao bem-sucedida com ops do TensorFlow")
                    print("   [AVISO] Modelo pode ser maior e mais lento devido ao uso de ops do TensorFlow")
                except Exception as e2:
                    print(f"   [ERRO] Falha na conversao mesmo com ops do TensorFlow: {e2}")
                    raise
            else:
                raise
        
        # Cria o diretório de saída se não existir
        output_dir = os.path.dirname(output_path)
        if output_dir and not os.path.exists(output_dir):
            os.makedirs(output_dir)
            print(f"   Criado diretorio: {output_dir}")
        
        # Salva o modelo TFLite
        with open(output_path, 'wb') as f:
            f.write(tflite_model)
        
        # Exibe informações do arquivo gerado
        file_size = os.path.getsize(output_path)
        file_size_mb = file_size / (1024 * 1024)
        
        print(f"\n[OK] Conversao concluida com sucesso!")
        print(f"   Arquivo salvo em: {output_path}")
        print(f"   Tamanho do arquivo: {file_size_mb:.2f} MB ({file_size:,} bytes)")
        
        # Verifica se o modelo pode ser carregado
        print("\n[INFO] Verificando integridade do modelo TFLite...")
        try:
            interpreter = tf.lite.Interpreter(model_path=output_path)
            interpreter.allocate_tensors()
            
            # Obtém informações de entrada e saída
            input_details = interpreter.get_input_details()
            output_details = interpreter.get_output_details()
            
            print("   [OK] Modelo TFLite valido!")
            print(f"\n[INFO] Detalhes do Modelo TFLite:")
            print(f"   Input:")
            print(f"     - Shape: {input_details[0]['shape']}")
            print(f"     - Tipo: {input_details[0]['dtype']}")
            print(f"   Output:")
            print(f"     - Shape: {output_details[0]['shape']}")
            print(f"     - Tipo: {output_details[0]['dtype']}")
            
            # Validação de precisão (se solicitado)
            if validate_precision:
                input_shape = model.input_shape[1:]  # Remove batch dimension
                validate_model_precision(model, output_path, input_shape)
            
        except Exception as e:
            print(f"   [AVISO] Erro ao verificar modelo: {e}")
            
    except Exception as e:
        print(f"\n[ERRO] Erro durante a conversao: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(
        description='Converte modelo Keras para TensorFlow Lite',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Exemplos:
  # Conversão com otimizações (padrão - recomendado)
  python convert_model.py --input model.keras --output assets/model.tflite
  
  # Conversão sem otimizações (modelo maior, mas mais preciso)
  python convert_model.py --input model.keras --output assets/model.tflite --no-optimize
  
  # Conversão com validação de precisão
  python convert_model.py --input model.keras --output assets/model.tflite --validate-precision
        """
    )
    
    parser.add_argument(
        '--input', '-i',
        type=str,
        required=True,
        help='Caminho para o arquivo .keras'
    )
    
    parser.add_argument(
        '--output', '-o',
        type=str,
        default='assets/model.tflite',
        help='Caminho onde salvar o arquivo .tflite (padrão: assets/model.tflite)'
    )
    
    parser.add_argument(
        '--no-optimize',
        action='store_true',
        help='Desabilita otimizações (por padrão, otimizações estão habilitadas)'
    )
    
    parser.add_argument(
        '--validate-precision',
        action='store_true',
        help='Valida precisão comparando predições Keras vs TFLite (opcional)'
    )
    
    args = parser.parse_args()
    
    print("=" * 60)
    print("Conversor Keras -> TensorFlow Lite (Melhorado)")
    print("=" * 60)
    print()
    
    # Por padrão, otimizações estão habilitadas (melhor para produção)
    optimize = not args.no_optimize
    
    if optimize:
        print("[INFO] Otimizacoes habilitadas (padrao)")
    else:
        print("[INFO] Otimizacoes desabilitadas")
    
    if args.validate_precision:
        print("[INFO] Validacao de precisao habilitada")
    
    print()
    
    convert_keras_to_tflite(
        args.input, 
        args.output, 
        optimize=optimize,
        validate_precision=args.validate_precision
    )
    
    print("\n" + "=" * 60)
    print("[SUCESSO] Processo concluido!")
    print("=" * 60)


if __name__ == '__main__':
    main()