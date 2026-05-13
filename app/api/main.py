import boto3
import logging
import os
from datetime import datetime
from fastapi import FastAPI, HTTPException
from boto3.dynamodb.conditions import Key

# Configuração de logs estruturados para o CloudWatch
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = FastAPI(title="Banco X — API Interna")

# Configurações via variáveis de ambiente (definidas na task definition)
DYNAMODB_TABLE = os.getenv("DYNAMODB_TABLE", "bancox-dev-contas")
AWS_REGION = os.getenv("AWS_REGION", "us-east-1")

dynamodb = boto3.resource("dynamodb", region_name=AWS_REGION)
table = dynamodb.Table(DYNAMODB_TABLE)


@app.get("/health")
def health_check():
    """
    Endpoint de health check usado pelo ALB.
    Se esse endpoint responder 200, o ALB considera a task saudável.
    """
    return {"status": "healthy", "service": "Banco X API", "timestamp": datetime.utcnow().isoformat()}


@app.get("/saldo/{conta_id}")
def consultar_saldo(conta_id: str):
    """
    Consulta o saldo de uma conta bancária.
    Registra a consulta no CloudWatch para auditoria.
    """
    try:
        response = table.get_item(Key={"conta_id": conta_id})
        item = response.get("Item")

        if not item:
            logger.warning(f"Consulta para conta inexistente: {conta_id}")
            raise HTTPException(status_code=404, detail="Conta não encontrada")

        # Log de auditoria — toda consulta é registrada
        logger.info(f"AUDITORIA | conta={conta_id} | titular={item['titular']} | timestamp={datetime.utcnow().isoformat()}")

        return {
            "conta_id": item["conta_id"],
            "titular": item["titular"],
            "agencia": item["agencia"],
            "saldo": float(item["saldo"]),
            "consultado_em": datetime.utcnow().isoformat()
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Erro ao consultar conta {conta_id}: {str(e)}")
        raise HTTPException(status_code=500, detail="Erro interno do servidor")