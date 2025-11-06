"""
Script para testar inferência do modelo Keras e comparar com o comportamento esperado
"""
import numpy as np
import tensorflow as tf
from PIL import Image
import sys
import os

# Configurar encoding UTF-8 para Windows
if sys.platform == 'win32':
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')

def test_keras_inference(model_path, image_path=None):
    """Testa inferência do modelo Keras"""
    print("=" * 60)
    print("TESTE DE INFERÊNCIA - MODELO KERAS")
    print("=" * 60)
    
    # Carrega o modelo
    print(f"\n[1] Carregando modelo: {model_path}")
    model = tf.keras.models.load_model(model_path, compile=False)
    
    # Testa com entrada aleatória normalizada [0-1]
    print(f"\n[2] Teste com entrada aleatória normalizada [0-1]:")
    test_input_random = np.random.rand(1, 256, 256, 3).astype(np.float32)
    print(f"   Input shape: {test_input_random.shape}")
    print(f"   Input dtype: {test_input_random.dtype}")
    print(f"   Input range: [{test_input_random.min():.4f}, {test_input_random.max():.4f}]")
    
    output_random = model.predict(test_input_random, verbose=0)
    print(f"   Output shape: {output_random.shape}")
    print(f"   Output dtype: {output_random.dtype}")
    print(f"   Output range: [{output_random.min():.6f}, {output_random.max():.6f}]")
    print(f"   Output mean: {output_random.mean():.6f}")
    print(f"   Output std: {output_random.std():.6f}")
    
    # Conta pixels acima de diferentes thresholds
    print(f"\n[3] Análise de Thresholds:")
    thresholds = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]
    for threshold in thresholds:
        pixels_above = np.sum(output_random > threshold)
        percentage = (pixels_above / (256 * 256)) * 100
        print(f"   Threshold {threshold:.1f}: {pixels_above:6d} pixels ({percentage:5.2f}%)")
    
    # Testa com imagem real se fornecida
    if image_path and os.path.exists(image_path):
        print(f"\n[4] Teste com imagem real: {image_path}")
        try:
            # Carrega e pré-processa a imagem
            img = Image.open(image_path)
            print(f"   Imagem original: {img.size} ({img.mode})")
            
            # Redimensiona para 256x256
            img_resized = img.resize((256, 256), Image.Resampling.LANCZOS)
            
            # Converte para array numpy e normaliza para [0-1]
            img_array = np.array(img_resized).astype(np.float32)
            
            # Se a imagem tem canal alpha, remove
            if img_array.shape[2] == 4:
                img_array = img_array[:, :, :3]
            
            # Normaliza para [0-1]
            if img_array.max() > 1.0:
                img_array = img_array / 255.0
            
            # Adiciona dimensão de batch
            img_input = np.expand_dims(img_array, axis=0)
            
            print(f"   Input shape: {img_input.shape}")
            print(f"   Input range: [{img_input.min():.4f}, {img_input.max():.4f}]")
            
            # Executa inferência
            output_real = model.predict(img_input, verbose=0)
            
            print(f"   Output shape: {output_real.shape}")
            print(f"   Output range: [{output_real.min():.6f}, {output_real.max():.6f}]")
            print(f"   Output mean: {output_real.mean():.6f}")
            print(f"   Output std: {output_real.std():.6f}")
            
            # Análise de thresholds para imagem real
            print(f"\n[5] Análise de Thresholds (Imagem Real):")
            for threshold in thresholds:
                pixels_above = np.sum(output_real > threshold)
                percentage = (pixels_above / (256 * 256)) * 100
                print(f"   Threshold {threshold:.1f}: {pixels_above:6d} pixels ({percentage:5.2f}%)")
            
            # Salva máscara para visualização
            mask = (output_real[0, :, :, 0] > 0.3).astype(np.uint8) * 255
            mask_img = Image.fromarray(mask, mode='L')
            mask_path = image_path.replace('.jpg', '_mask_keras.jpg').replace('.png', '_mask_keras.png')
            mask_img.save(mask_path)
            print(f"\n   Máscara salva em: {mask_path}")
            
        except Exception as e:
            print(f"   [ERRO] Não foi possível processar imagem: {e}")
    
    # Testa formato de entrada esperado
    print(f"\n[6] Verificação de Formato de Entrada:")
    print(f"   Modelo espera: shape={model.input_shape}")
    print(f"   Formato testado: shape=(1, 256, 256, 3), dtype=float32")
    
    # Verifica se há normalização no modelo
    print(f"\n[7] Verificação de Normalização no Modelo:")
    first_layer = model.layers[0]
    print(f"   Primeira camada: {first_layer.name} ({type(first_layer).__name__})")
    if hasattr(first_layer, 'scale') or hasattr(first_layer, 'offset'):
        print(f"   [AVISO] Modelo pode ter normalização interna!")
    else:
        print(f"   [OK] Modelo não tem normalização interna - pré-processamento externo necessário")
    
    return model

def compare_with_tflite(keras_model, tflite_path, test_input):
    """Compara saída Keras vs TFLite"""
    print(f"\n[8] Comparação Keras vs TFLite:")
    
    if not os.path.exists(tflite_path):
        print(f"   [AVISO] TFLite não encontrado: {tflite_path}")
        return
    
    try:
        # Keras
        keras_output = keras_model.predict(test_input, verbose=0)
        
        # TFLite
        interpreter = tf.lite.Interpreter(model_path=tflite_path)
        interpreter.allocate_tensors()
        
        input_details = interpreter.get_input_details()
        output_details = interpreter.get_output_details()
        
        interpreter.set_tensor(input_details[0]['index'], test_input)
        interpreter.invoke()
        tflite_output = interpreter.get_tensor(output_details[0]['index'])
        
        # Compara
        diff = np.abs(keras_output - tflite_output)
        print(f"   Diferença média: {diff.mean():.6f}")
        print(f"   Diferença máxima: {diff.max():.6f}")
        print(f"   Diferença mínima: {diff.min():.6f}")
        print(f"   Pixels com diferença > 0.01: {np.sum(diff > 0.01)}")
        print(f"   Pixels com diferença > 0.1: {np.sum(diff > 0.1)}")
        
        # Compara máscaras binarizadas
        threshold = 0.3
        keras_mask = (keras_output > threshold).astype(np.uint8)
        tflite_mask = (tflite_output > threshold).astype(np.uint8)
        
        mask_diff = np.abs(keras_mask - tflite_mask)
        print(f"\n   Máscaras binarizadas (threshold {threshold}):")
        print(f"   Pixels diferentes: {np.sum(mask_diff > 0)} ({np.sum(mask_diff > 0) / (256*256) * 100:.2f}%)")
        
    except Exception as e:
        print(f"   [ERRO] Erro na comparação: {e}")

if __name__ == '__main__':
    model_path = 'melhor_modelo_unet_metricas_completas.keras'
    tflite_path = 'assets/model.tflite'
    
    # Testa com entrada aleatória
    test_input = np.random.rand(1, 256, 256, 3).astype(np.float32)
    
    model = test_keras_inference(model_path)
    compare_with_tflite(model, tflite_path, test_input)
    
    # Testa com imagem real se fornecida
    if len(sys.argv) > 1:
        image_path = sys.argv[1]
        test_keras_inference(model_path, image_path)
    
    print("\n" + "=" * 60)
    print("TESTE CONCLUÍDO")
    print("=" * 60)

