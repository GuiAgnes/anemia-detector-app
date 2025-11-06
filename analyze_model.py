"""
Script para analisar o modelo Keras e identificar problemas na conversão/inferência
"""
import numpy as np
import tensorflow as tf
from PIL import Image
import sys

# Configurar encoding UTF-8 para Windows
if sys.platform == 'win32':
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')

def analyze_model(model_path):
    """Analisa o modelo Keras em detalhes"""
    print("=" * 60)
    print("ANÁLISE DO MODELO KERAS")
    print("=" * 60)
    
    # Carrega o modelo
    print(f"\n[1] Carregando modelo: {model_path}")
    model = tf.keras.models.load_model(model_path, compile=False)
    
    # Informações básicas
    print(f"\n[2] Informações do Modelo:")
    print(f"   Input shape: {model.input_shape}")
    print(f"   Output shape: {model.output_shape}")
    print(f"   Número de parâmetros: {model.count_params():,}")
    
    # Verifica camadas de entrada
    print(f"\n[3] Camada de Entrada:")
    input_layer = model.layers[0]
    print(f"   Nome: {input_layer.name}")
    print(f"   Tipo: {type(input_layer).__name__}")
    if hasattr(input_layer, 'dtype'):
        print(f"   Dtype: {input_layer.dtype}")
    
    # Verifica camadas de saída
    print(f"\n[4] Camada de Saída:")
    output_layer = model.layers[-1]
    print(f"   Nome: {output_layer.name}")
    print(f"   Tipo: {type(output_layer).__name__}")
    if hasattr(output_layer, 'activation'):
        print(f"   Ativação: {output_layer.activation}")
    
    # Procura por camadas de normalização
    print(f"\n[5] Camadas de Normalização/Pré-processamento:")
    normalization_layers = []
    for i, layer in enumerate(model.layers):
        layer_type = type(layer).__name__
        if 'Normalization' in layer_type or 'Rescaling' in layer_type or 'Rescale' in layer_type:
            normalization_layers.append((i, layer.name, layer_type))
            print(f"   Camada {i}: {layer.name} ({layer_type})")
            if hasattr(layer, 'scale'):
                print(f"      Scale: {layer.scale}")
            if hasattr(layer, 'offset'):
                print(f"      Offset: {layer.offset}")
    
    if not normalization_layers:
        print("   Nenhuma camada de normalização encontrada no modelo")
        print("   [IMPORTANTE] O pré-processamento deve ser feito externamente!")
    
    # Procura por camadas de ativação na saída
    print(f"\n[6] Ativação da Saída:")
    last_layer = model.layers[-1]
    if hasattr(last_layer, 'activation'):
        activation = last_layer.activation
        if activation is None:
            print("   Sem ativação (saída linear)")
        else:
            print(f"   Ativação: {activation}")
            if hasattr(activation, '__name__'):
                print(f"   Nome: {activation.__name__}")
    else:
        print("   Não foi possível determinar a ativação")
    
    # Testa com entrada de exemplo
    print(f"\n[7] Teste de Inferência:")
    test_input = np.random.rand(1, 256, 256, 3).astype(np.float32)
    print(f"   Input shape: {test_input.shape}")
    print(f"   Input dtype: {test_input.dtype}")
    print(f"   Input range: [{test_input.min():.4f}, {test_input.max():.4f}]")
    
    output = model.predict(test_input, verbose=0)
    print(f"   Output shape: {output.shape}")
    print(f"   Output dtype: {output.dtype}")
    print(f"   Output range: [{output.min():.6f}, {output.max():.6f}]")
    print(f"   Output mean: {output.mean():.6f}")
    print(f"   Output std: {output.std():.6f}")
    
    # Testa com entrada normalizada [0-1]
    print(f"\n[8] Teste com Entrada Normalizada [0-1]:")
    test_input_norm = np.random.rand(1, 256, 256, 3).astype(np.float32)
    output_norm = model.predict(test_input_norm, verbose=0)
    print(f"   Output range: [{output_norm.min():.6f}, {output_norm.max():.6f}]")
    print(f"   Output mean: {output_norm.mean():.6f}")
    
    # Testa com entrada em escala [0-255] normalizada
    print(f"\n[9] Teste com Entrada [0-255] Normalizada para [0-1]:")
    test_input_255 = np.random.randint(0, 256, (1, 256, 256, 3)).astype(np.float32) / 255.0
    output_255 = model.predict(test_input_255, verbose=0)
    print(f"   Output range: [{output_255.min():.6f}, {output_255.max():.6f}]")
    print(f"   Output mean: {output_255.mean():.6f}")
    
    # Verifica se a saída parece ser probabilidades ou logits
    print(f"\n[10] Análise da Saída:")
    if output.min() >= 0 and output.max() <= 1:
        print("   [INFO] Saída está no range [0, 1] - pode ser probabilidade ou sigmoid")
        if output.mean() < 0.1:
            print("   [AVISO] Média muito baixa - pode precisar de threshold baixo")
        elif output.mean() > 0.9:
            print("   [AVISO] Média muito alta - pode estar saturado")
    else:
        print(f"   [INFO] Saída está no range [{output.min():.2f}, {output.max():.2f}]")
        print("   [AVISO] Saída pode ser logits (não normalizada)")
        print("   [DICA] Pode precisar aplicar sigmoid ou softmax")
    
    return model

def compare_with_tflite(keras_model, tflite_path=None):
    """Compara modelo Keras com TFLite se disponível"""
    if tflite_path and tf.io.gfile.exists(tflite_path):
        print(f"\n[11] Comparação Keras vs TFLite:")
        print(f"   Carregando TFLite: {tflite_path}")
        
        interpreter = tf.lite.Interpreter(model_path=tflite_path)
        interpreter.allocate_tensors()
        
        input_details = interpreter.get_input_details()
        output_details = interpreter.get_output_details()
        
        print(f"   TFLite Input shape: {input_details[0]['shape']}")
        print(f"   TFLite Input dtype: {input_details[0]['dtype']}")
        print(f"   TFLite Output shape: {output_details[0]['shape']}")
        print(f"   TFLite Output dtype: {output_details[0]['dtype']}")
        
        # Teste com mesma entrada
        test_input = np.random.rand(1, 256, 256, 3).astype(np.float32)
        
        # Keras
        keras_output = keras_model.predict(test_input, verbose=0)
        
        # TFLite
        interpreter.set_tensor(input_details[0]['index'], test_input)
        interpreter.invoke()
        tflite_output = interpreter.get_tensor(output_details[0]['index'])
        
        # Compara
        diff = np.abs(keras_output - tflite_output).mean()
        max_diff = np.abs(keras_output - tflite_output).max()
        
        print(f"\n   Diferença média: {diff:.6f}")
        print(f"   Diferença máxima: {max_diff:.6f}")
        
        if diff > 0.01:
            print(f"   [AVISO] Diferença significativa entre Keras e TFLite!")
            print(f"   Isso pode indicar problemas na conversão")
    else:
        print(f"\n[11] TFLite não encontrado para comparação")

if __name__ == '__main__':
    model_path = 'melhor_modelo_unet_metricas_completas.keras'
    tflite_path = 'assets/model.tflite'
    
    model = analyze_model(model_path)
    compare_with_tflite(model, tflite_path)
    
    print("\n" + "=" * 60)
    print("ANÁLISE CONCLUÍDA")
    print("=" * 60)

