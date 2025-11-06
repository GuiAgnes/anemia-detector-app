"""
Script para testar o uso correto do TFLite e comparar com Keras
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

def test_tflite_usage(tflite_path, keras_model_path=None):
    """Testa o uso correto do TFLite"""
    print("=" * 60)
    print("TESTE DE USO DO TFLITE")
    print("=" * 60)
    
    # Carrega o modelo TFLite
    print(f"\n[1] Carregando modelo TFLite: {tflite_path}")
    interpreter = tf.lite.Interpreter(model_path=tflite_path)
    interpreter.allocate_tensors()
    
    # Obtém informações de entrada e saída
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    
    print(f"\n[2] Informações do Modelo TFLite:")
    print(f"   Input:")
    print(f"     - Shape: {input_details[0]['shape']}")
    print(f"     - Dtype: {input_details[0]['dtype']}")
    print(f"     - Index: {input_details[0]['index']}")
    print(f"   Output:")
    print(f"     - Shape: {output_details[0]['shape']}")
    print(f"     - Dtype: {output_details[0]['dtype']}")
    print(f"     - Index: {output_details[0]['index']}")
    
    # Testa com entrada aleatória normalizada [0-1]
    print(f"\n[3] Teste com entrada aleatória normalizada [0-1]:")
    test_input = np.random.rand(1, 256, 256, 3).astype(np.float32)
    print(f"   Input shape: {test_input.shape}")
    print(f"   Input dtype: {test_input.dtype}")
    print(f"   Input range: [{test_input.min():.4f}, {test_input.max():.4f}]")
    
    # Método 1: Usando setTensor e invoke (recomendado)
    print(f"\n[4] Método 1: Usando setTensor e invoke (recomendado):")
    interpreter.set_tensor(input_details[0]['index'], test_input)
    interpreter.invoke()
    output1 = interpreter.get_tensor(output_details[0]['index'])
    
    print(f"   Output shape: {output1.shape}")
    print(f"   Output dtype: {output1.dtype}")
    print(f"   Output range: [{output1.min():.6f}, {output1.max():.6f}]")
    print(f"   Output mean: {output1.mean():.6f}")
    print(f"   Output std: {output1.std():.6f}")
    
    # Compara com Keras se disponível
    if keras_model_path:
        print(f"\n[5] Comparação com Keras:")
        keras_model = tf.keras.models.load_model(keras_model_path, compile=False)
        keras_output = keras_model.predict(test_input, verbose=0)
        
        diff = np.abs(output1 - keras_output)
        print(f"   Diferença média: {diff.mean():.6f}")
        print(f"   Diferença máxima: {diff.max():.6f}")
        print(f"   Pixels com diferença > 0.01: {np.sum(diff > 0.01)}")
        
        # Compara máscaras binarizadas
        threshold = 0.3
        tflite_mask = (output1 > threshold).astype(np.uint8)
        keras_mask = (keras_output > threshold).astype(np.uint8)
        
        mask_diff = np.abs(tflite_mask - keras_mask)
        print(f"\n   Máscaras binarizadas (threshold {threshold}):")
        print(f"   Pixels diferentes: {np.sum(mask_diff > 0)} ({np.sum(mask_diff > 0) / (256*256) * 100:.2f}%)")
    
    # Testa formato de entrada como lista aninhada (como no código Dart)
    print(f"\n[6] Teste com formato de lista aninhada (como no código Dart):")
    # Converte para lista aninhada [1][256][256][3]
    input_nested = test_input.tolist()
    
    # Tenta usar com run (como no código Dart)
    output2 = np.zeros((1, 256, 256, 1), dtype=np.float32)
    try:
        # O TFLite Python não suporta run() da mesma forma que o Flutter
        # Mas podemos simular verificando se o formato está correto
        print(f"   Formato de entrada (lista aninhada): OK")
        print(f"   Shape da lista: {len(input_nested)} x {len(input_nested[0])} x {len(input_nested[0][0])} x {len(input_nested[0][0][0])}")
        
        # Verifica se os valores são os mesmos
        input_from_nested = np.array(input_nested, dtype=np.float32)
        if np.allclose(test_input, input_from_nested):
            print(f"   [OK] Conversão para lista aninhada preserva valores")
        else:
            print(f"   [ERRO] Conversão para lista aninhada altera valores!")
            diff = np.abs(test_input - input_from_nested)
            print(f"   Diferença máxima: {diff.max():.6f}")
    except Exception as e:
        print(f"   [ERRO] Erro ao testar formato de lista aninhada: {e}")
    
    # Testa com imagem real se fornecida
    if len(sys.argv) > 1:
        image_path = sys.argv[1]
        print(f"\n[7] Teste com imagem real: {image_path}")
        try:
            img = Image.open(image_path)
            img_resized = img.resize((256, 256), Image.Resampling.LANCZOS)
            img_array = np.array(img_resized).astype(np.float32)
            
            if img_array.shape[2] == 4:
                img_array = img_array[:, :, :3]
            
            if img_array.max() > 1.0:
                img_array = img_array / 255.0
            
            img_input = np.expand_dims(img_array, axis=0)
            
            interpreter.set_tensor(input_details[0]['index'], img_input)
            interpreter.invoke()
            output_real = interpreter.get_tensor(output_details[0]['index'])
            
            print(f"   Output range: [{output_real.min():.6f}, {output_real.max():.6f}]")
            print(f"   Output mean: {output_real.mean():.6f}")
            
            # Análise de thresholds
            thresholds = [0.1, 0.2, 0.3, 0.4, 0.5]
            print(f"\n   Análise de Thresholds:")
            for threshold in thresholds:
                pixels_above = np.sum(output_real > threshold)
                percentage = (pixels_above / (256 * 256)) * 100
                print(f"   Threshold {threshold:.1f}: {pixels_above:6d} pixels ({percentage:5.2f}%)")
            
        except Exception as e:
            print(f"   [ERRO] Erro ao processar imagem: {e}")

if __name__ == '__main__':
    tflite_path = 'assets/model.tflite'
    keras_path = 'melhor_modelo_unet_metricas_completas.keras'
    
    test_tflite_usage(tflite_path, keras_path)
    
    print("\n" + "=" * 60)
    print("TESTE CONCLUÍDO")
    print("=" * 60)

