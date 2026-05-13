#!/usr/bin/env python3
import boto3
import requests
import json
import sys
from datetime import datetime

# Perfil AWS do funcionário
AWS_PROFILE = "bancox-funcionario"
AWS_REGION = "us-east-1"
SECRET_NAME = "bancox/dev/config"

BANNER = """
╔══════════════════════════════════════╗
║                                      ║
║           B A N C O   X             ║
║      Sistema Interno de Consulta     ║
║                                      ║
╚══════════════════════════════════════╝
"""

def buscar_configuracao():
    """Busca a configuração do sistema no Secrets Manager."""
    try:
        session = boto3.Session(profile_name=AWS_PROFILE, region_name=AWS_REGION)
        client = session.client("secretsmanager")

        response = client.get_secret_value(SecretId=SECRET_NAME)
        config = json.loads(response["SecretString"])

        print(f"  Ambiente : {config['environment'].upper()}")
        print(f"  Versão   : {config['version']}\n")

        return config

    except client.exceptions.AccessDeniedException:
        print("❌ Acesso negado ao Secrets Manager. Verifique suas permissões.")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Erro ao buscar configuração: {e}")
        sys.exit(1)


def consultar_saldo(alb_url: str, conta_id: str):
    """Faz a consulta de saldo via ALB."""
    try:
        response = requests.get(
            f"{alb_url}/saldo/{conta_id}",
            timeout=5
        )

        if response.status_code == 404:
            print("\n❌ Conta não encontrada.")
            return

        if response.status_code != 200:
            print(f"\n❌ Erro na consulta: {response.status_code}")
            return

        dados = response.json()
        saldo = f"R$ {dados['saldo']:,.2f}".replace(",", "X").replace(".", ",").replace("X", ".")
        horario = datetime.now().strftime("%d/%m/%Y %H:%M:%S")

        print(f"""
┌─────────────────────────────────────────┐
│              BANCO X                    │
│         Consulta de Saldo               │
├─────────────────────────────────────────┤
│  Agência  : {dados['agencia']:<29}│
│  Conta    : {dados['conta_id']:<29}│
│  Titular  : {dados['titular']:<29}│
├─────────────────────────────────────────┤
│  Saldo    : {saldo:<29}│
├─────────────────────────────────────────┤
│  Consultado em: {horario:<24}│
└─────────────────────────────────────────┘
""")

    except requests.exceptions.ConnectionError:
        print("\n❌ Não foi possível conectar ao sistema.")
    except Exception as e:
        print(f"\n❌ Erro inesperado: {e}")


def main():
    print(BANNER)
    print("  Conectando ao sistema Banco X...")
    print("  Buscando configuração no Secrets Manager...\n")

    config = buscar_configuracao()
    alb_url = config["alb_url"]

    try:
        while True:
            conta_id = input("  Número da conta (ou 'sair'): ").strip()

            if conta_id.lower() == "sair":
                print("\n  Encerrando sessão. Até logo!\n")
                break

            if not conta_id:
                continue

            consultar_saldo(alb_url, conta_id)

    except KeyboardInterrupt:
        print("\n\n  Sessão encerrada.\n")


if __name__ == "__main__":
    main()