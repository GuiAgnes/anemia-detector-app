# Mobile Anemia Detector

Aplicativo móvel para diagnóstico de anemia em ovinos usando Machine Learning on-device.

## Características

- Captura de foto da conjuntiva ocular de ovinos
- Recorte de imagem para focar na área de interesse
- Processamento de imagem on-device
- Classificação usando modelo TFLite
- Score FAMACHA (1-5) e status de anemia

## Requisitos

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Modelo TFLite em `assets/model.tflite`

## Instalação

1. Clone o repositório
2. Execute `flutter pub get`
3. **Converta seu modelo `.keras` para `.tflite`** (veja [CONVERSAO_MODELO.md](CONVERSAO_MODELO.md))
   ```bash
   python convert_model.py --input seu_modelo.keras --output assets/model.tflite
   ```
4. Execute `flutter run`

## Conversão do Modelo

Se você tem um modelo `.keras`, use o script de conversão:

```bash
# Instalar TensorFlow
pip install -r requirements.txt

# Converter modelo
python convert_model.py --input seu_modelo.keras --output assets/model.tflite
```

Para mais detalhes, consulte [CONVERSAO_MODELO.md](CONVERSAO_MODELO.md).

