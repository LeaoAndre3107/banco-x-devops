#!/bin/bash
set -e

echo "╔══════════════════════════════════════╗"
echo "║    Banco X — Setup do Funcionário    ║"
echo "╚══════════════════════════════════════╝"
echo ""

# Verifica AWS CLI
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI não encontrado. Instale em: https://aws.amazon.com/cli/"
    exit 1
fi
echo "✅ AWS CLI encontrado"

# Instala plugin SSM
if ! aws ssm start-session --help &> /dev/null; then
    echo "📦 Instalando plugin SSM Session Manager..."
    curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" \
        -o /tmp/session-manager-plugin.deb
    sudo dpkg -i /tmp/session-manager-plugin.deb
fi
echo "✅ Plugin SSM instalado"

# Instala dependências Python do CLI
echo "📦 Instalando dependências do CLI..."
pip install requests boto3 --quiet
echo "✅ Dependências instaladas"

echo ""
echo "✅ Setup concluído! Para usar o sistema:"
echo "   python3 bancox_cli.py"
echo ""