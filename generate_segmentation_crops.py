"""
Script para gerar recortes de imagens usando segmentação com modelo Keras

Este script carrega um modelo .keras de segmentação, processa imagens de um diretório,
e gera máscaras binárias e recortes das regiões segmentadas.

Uso:
    python generate_segmentation_crops.py --model melhor_modelo_unet_metricas_completas.keras --input assets/images/examples --output results
    python generate_segmentation_crops.py --model melhor_modelo_unet_metricas_completas.keras --input assets/images/examples --output results --threshold 0.3
"""

import argparse
import os
import sys
import numpy as np
import cv2
import tensorflow as tf

# Configurar encoding UTF-8 para Windows
if sys.platform == 'win32':
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')

# Constantes do modelo (baseadas em MLConstants do Flutter)
IMG_HEIGHT = 256
IMG_WIDTH = 256
SEGMENTATION_THRESHOLD = 0.3  # Threshold padrão para binarização
MIN_COVERAGE_PERCENTAGE = 0.1  # Porcentagem mínima de cobertura


def preprocess_inference_image(image_path, target_height, target_width):
    """
    Pré-processa uma imagem para inferência
    
    Args:
        image_path: Caminho para a imagem
        target_height: Altura alvo
        target_width: Largura alvo
    
    Returns:
        tuple: (imagem pré-processada, imagem original redimensionada)
    """
    img = cv2.imread(image_path)
    if img is None:
        raise IOError(f"Não foi possível ler a imagem: {image_path}")
    
    # Converte BGR para RGB
    img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    
    # Redimensiona para o tamanho do modelo
    img_resized_original = cv2.resize(img_rgb, (target_width, target_height))
    
    # Normaliza para [0, 1] (conforme usado no Flutter)
    img_float = img_resized_original.astype(np.float32) / 255.0
    
    return img_float, img_resized_original


def process_images(model_path, input_dir, output_dir, threshold=SEGMENTATION_THRESHOLD):
    """
    Processa imagens usando o modelo de segmentação
    
    Args:
        model_path: Caminho para o arquivo .keras
        input_dir: Diretório com imagens de entrada
        output_dir: Diretório base para salvar resultados
        threshold: Threshold para binarização da máscara
    """
    # Cria diretórios de saída
    results_masks_path = os.path.join(output_dir, 'masks')
    results_overlays_path = os.path.join(output_dir, 'crops')
    
    os.makedirs(results_masks_path, exist_ok=True)
    os.makedirs(results_overlays_path, exist_ok=True)
    
    # --- Carregar o Modelo de Segmentação ---
    print(f"Carregando modelo treinado de: {model_path}")
    try:
        # Para inferência, podemos usar compile=False
        model_inference = tf.keras.models.load_model(model_path, compile=False)
        print("Modelo de inferência carregado com sucesso.")
        print(f"   Input shape: {model_inference.input_shape}")
        print(f"   Output shape: {model_inference.output_shape}")
    except Exception as e:
        print(f"ERRO CRÍTICO ao carregar o modelo: {e}")
        return
    
    # --- Processamento em Lote das Imagens ---
    image_extensions = ('.png', '.jpg', '.jpeg', '.bmp', '.tiff', '.tif')
    image_files = sorted([
        f for f in os.listdir(input_dir)
        if f.lower().endswith(image_extensions)
        and os.path.isfile(os.path.join(input_dir, f))
    ])
    
    if not image_files:
        print(f"AVISO: Nenhuma imagem encontrada no diretório: {input_dir}")
        return
    
    print(f"\nIniciando predição para {len(image_files)} imagens...")
    print(f"Threshold de segmentação: {threshold}")
    print(f"Tamanho de entrada do modelo: {IMG_WIDTH}x{IMG_HEIGHT}")
    
    successful = 0
    failed = 0
    
    for filename in image_files:
        image_path = os.path.join(input_dir, filename)
        try:
            # Pré-processa a imagem
            processed_img, resized_original_img = preprocess_inference_image(
                image_path, IMG_HEIGHT, IMG_WIDTH
            )
            
            # Faz a predição
            predicted_mask_raw = model_inference.predict(
                np.expand_dims(processed_img, axis=0),
                verbose=0
            )[0]
            
            # Remove dimensão extra se necessário (pode ser [256, 256, 1] ou [256, 256])
            if len(predicted_mask_raw.shape) == 3:
                if predicted_mask_raw.shape[2] == 1:
                    predicted_mask_raw = predicted_mask_raw[:, :, 0]
            
            # Estatísticas da predição
            pred_max = np.max(predicted_mask_raw)
            pred_min = np.min(predicted_mask_raw)
            pred_mean = np.mean(predicted_mask_raw)
            
            print(f"\n   - Processando '{filename}':")
            print(f"     Valor Máximo da Predição: {pred_max:.4f}")
            print(f"     Valor Mínimo da Predição: {pred_min:.4f}")
            print(f"     Valor Médio da Predição: {pred_mean:.4f}")
            
            # Threshold adaptativo: se o valor máximo for muito baixo (< 0.1),
            # usa uma porcentagem do valor máximo como threshold
            if pred_max < 0.1:
                adaptive_threshold = pred_max * 0.3  # 30% do valor máximo
                print(f"     -> Usando threshold adaptativo: {adaptive_threshold:.6f} (30% do máximo)")
                actual_threshold = adaptive_threshold
            else:
                actual_threshold = threshold
            
            # Binariza a máscara usando o threshold (fixo ou adaptativo)
            binary_mask = (predicted_mask_raw > actual_threshold).astype(np.uint8)
            
            # Verifica cobertura
            coverage_percentage = (np.sum(binary_mask) / binary_mask.size) * 100
            
            if coverage_percentage < MIN_COVERAGE_PERCENTAGE:
                print(f"     -> AVISO: Cobertura muito baixa ({coverage_percentage:.2f}%)")
                print(f"        Nenhuma mucosa foi segmentada em '{filename}'.")
            else:
                print(f"     -> Cobertura: {coverage_percentage:.2f}%")
            
            # Salva a máscara binária
            mask_save_path = os.path.join(results_masks_path, f"mascara_{filename}")
            cv2.imwrite(mask_save_path, binary_mask * 255)
            
            # Gera o recorte aplicando a máscara na imagem original
            # Aplica a máscara na imagem redimensionada
            overlay_img = cv2.bitwise_and(
                resized_original_img,
                resized_original_img,
                mask=binary_mask
            )
            
            # Salva o recorte (converte RGB para BGR para OpenCV)
            overlay_save_path = os.path.join(results_overlays_path, f"recorte_{filename}")
            cv2.imwrite(overlay_save_path, cv2.cvtColor(overlay_img, cv2.COLOR_RGB2BGR))
            
            successful += 1
            
        except Exception as e:
            print(f"   - ERRO CRÍTICO ao processar '{filename}': {e}")
            failed += 1
    
    print("\n" + "=" * 60)
    print("Análise de imagens concluída!")
    print(f"   Sucesso: {successful}")
    print(f"   Falhas: {failed}")
    print(f"   Total: {len(image_files)}")
    print(f"\nVerifique os resultados em:")
    print(f"   - Máscaras: {results_masks_path}")
    print(f"   - Recortes: {results_overlays_path}")
    print("=" * 60)


def main():
    parser = argparse.ArgumentParser(
        description='Gera recortes de imagens usando segmentação com modelo Keras',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Exemplos:
  # Uso básico
  python generate_segmentation_crops.py --model melhor_modelo_unet_metricas_completas.keras --input assets/images/examples
  
  # Especificando diretório de saída
  python generate_segmentation_crops.py --model melhor_modelo_unet_metricas_completas.keras --input assets/images/examples --output results
  
  # Ajustando threshold
  python generate_segmentation_crops.py --model melhor_modelo_unet_metricas_completas.keras --input assets/images/examples --threshold 0.5
        """
    )
    
    parser.add_argument(
        '--model', '-m',
        type=str,
        required=True,
        help='Caminho para o arquivo .keras do modelo'
    )
    
    parser.add_argument(
        '--input', '-i',
        type=str,
        required=True,
        help='Diretório com imagens de entrada'
    )
    
    parser.add_argument(
        '--output', '-o',
        type=str,
        default='results',
        help='Diretório base para salvar resultados (padrão: results)'
    )
    
    parser.add_argument(
        '--threshold', '-t',
        type=float,
        default=SEGMENTATION_THRESHOLD,
        help=f'Threshold para binarização da máscara (padrão: {SEGMENTATION_THRESHOLD})'
    )
    
    args = parser.parse_args()
    
    # Validações
    if not os.path.exists(args.model):
        print(f"ERRO: Arquivo do modelo não encontrado: {args.model}")
        sys.exit(1)
    
    if not os.path.exists(args.input):
        print(f"ERRO: Diretório de entrada não encontrado: {args.input}")
        sys.exit(1)
    
    if not os.path.isdir(args.input):
        print(f"ERRO: Caminho de entrada não é um diretório: {args.input}")
        sys.exit(1)
    
    if not (0.0 <= args.threshold <= 1.0):
        print(f"ERRO: Threshold deve estar entre 0.0 e 1.0 (recebido: {args.threshold})")
        sys.exit(1)
    
    # Processa as imagens
    process_images(args.model, args.input, args.output, args.threshold)


if __name__ == '__main__':
    main()

