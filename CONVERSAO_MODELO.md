# Guia de Conversão do Modelo

Este guia explica como converter seu modelo `.keras` para o formato `.tflite` necessário para o aplicativo Flutter.

## Pré-requisitos

1. **Python 3.8 ou superior** instalado
2. **TensorFlow** instalado (versão 2.13.0 ou superior)

## Instalação

### 1. Instalar TensorFlow

```bash
pip install tensorflow
```

Ou usando o arquivo `requirements.txt`:

```bash
pip install -r requirements.txt
```

## Conversão do Modelo

### Método 1: Usando o script Python (Recomendado)

O script `convert_model.py` automatiza todo o processo de conversão:

```bash
# Conversão básica
python convert_model.py --input seu_modelo.keras --output assets/model.tflite

# Conversão com otimizações (reduz o tamanho do arquivo)
python convert_model.py --input seu_modelo.keras --output assets/model.tflite --optimize
```

**Parâmetros:**
- `--input` ou `-i`: Caminho para o arquivo `.keras`
- `--output` ou `-o`: Caminho onde salvar o `.tflite` (padrão: `assets/model.tflite`)
- `--optimize`: Aplica otimizações (quantização) para reduzir o tamanho

### Método 2: Conversão Manual (Python)

Se preferir fazer manualmente, você pode usar este código Python:

```python
import tensorflow as tf

# Carrega o modelo Keras
model = tf.keras.models.load_model('seu_modelo.keras')

# Converte para TFLite
converter = tf.lite.TFLiteConverter.from_keras_model(model)

# Opcional: Aplica otimizações
converter.optimizations = [tf.lite.Optimize.DEFAULT]

# Converte
tflite_model = converter.convert()

# Salva o arquivo
with open('assets/model.tflite', 'wb') as f:
    f.write(tflite_model)

print("Conversão concluída!")
```

## Verificações Importantes

### 1. Formato de Entrada

O modelo deve ter:
- **Input Shape**: `(None, 256, 256, 3)`
- **Input Type**: `float32`
- **Normalização**: Valores entre `[0, 1]` (não `[0, 255]`)

### 2. Formato de Saída

O modelo deve ter:
- **Output Shape**: `(None, 5)`
- **Output Type**: `float32`
- **Significado**: Array de 5 probabilidades (uma para cada score FAMACHA 1-5)

### 3. Verificação do Modelo

Após a conversão, você pode verificar o modelo com:

```python
import tensorflow as tf

# Carrega o modelo TFLite
interpreter = tf.lite.Interpreter(model_path='assets/model.tflite')
interpreter.allocate_tensors()

# Obtém informações
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

print("Input:", input_details[0]['shape'], input_details[0]['dtype'])
print("Output:", output_details[0]['shape'], output_details[0]['dtype'])
```

## Otimizações

### Quantização Float16

Reduz o tamanho do arquivo em ~50% mantendo boa precisão:

```python
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.target_spec.supported_types = [tf.float16]
```

### Quantização Int8 (Avançado)

Reduz ainda mais o tamanho, mas requer dados de calibração:

```python
def representative_dataset():
    # Retorna um conjunto de dados de exemplo para calibração
    for _ in range(100):
        yield [np.random.rand(1, 256, 256, 3).astype(np.float32)]

converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.representative_dataset = representative_dataset
converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
converter.inference_input_type = tf.uint8
converter.inference_output_type = tf.uint8
```

## Troubleshooting

### Erro: "Model not found"
- Verifique se o caminho do arquivo `.keras` está correto
- Verifique se o arquivo existe

### Erro: "Input shape mismatch"
- Verifique se o modelo tem input shape `(None, 256, 256, 3)`
- Se necessário, ajuste o modelo ou o código de pré-processamento

### Erro: "Output shape mismatch"
- Verifique se o modelo tem output shape `(None, 5)`
- Se o modelo foi treinado para detecção de região (não classificação), você precisará ajustar o código

### Modelo muito grande
- Use a opção `--optimize` para aplicar quantização
- Isso reduzirá o tamanho do arquivo significativamente

## Nota sobre Modelos de Detecção de Região

Se seu modelo atual é para **detecção da região da mucosa** (não classificação FAMACHA), você tem duas opções:

1. **Treinar um novo modelo de classificação** baseado nas regiões detectadas
2. **Ajustar o código do aplicativo** para trabalhar com detecção de região primeiro, depois classificar

Se você quiser, posso ajudar a adaptar o código para trabalhar com detecção de região primeiro!

