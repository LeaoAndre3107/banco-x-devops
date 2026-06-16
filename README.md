# Banco X — Sistema Interno de Consulta Bancária

Sistema corporativo simulado com API interna, CLI para funcionários e infraestrutura AWS completa provisionada via Terraform.

---

## Arquitetura

![Arquitetura Banco X](docs/architecture.svg)

O sistema opera inteiramente em **subnet privada**, sem exposição direta à internet. O acesso do funcionário acontece via **SSM Session Manager** com port forwarding — zero porta 22 aberta.

---

### CLI em operação

![CLI Banco X](docs/cli-demo.png)

O CLI conecta ao ambiente via **Secrets Manager** na inicialização, buscando o endpoint da API dinamicamente. Suporta múltiplas consultas por sessão, com tratamento de conta não encontrada e exibição formatada de saldo.

---

## Stack

| Camada | Tecnologia | Decisão |
|---|---|---|
| Imagem base | Packer + AMI customizada | Bake de dependências — mais rápido e confiável que user_data |
| Infraestrutura | Terraform | Multi-ambiente dev/prod com módulos reutilizáveis |
| Compute API | ECS Fargate | Serverless — sem gerenciar VMs, escala automática |
| Compute Workers | ECS EC2 | Controle sobre instâncias para jobs internos |
| Aplicação | Python + FastAPI | API leve, moderna e fácil de containerizar |
| Container | Docker multi-stage + ECR | Imagem menor, mais segura, usuário não-root |
| Banco de dados | DynamoDB | Serverless, escala automática, isolado por ambiente |
| Acesso seguro | SSM Session Manager | Zero porta 22, acesso auditado, padrão bancário |
| Segredos | Secrets Manager | Zero credenciais hardcoded — CLI busca config dinamicamente |
| CI/CD | GitHub Actions + OIDC | Zero chaves estáticas no repositório |
| Observabilidade | CloudWatch Logs + Alarmes | Auditoria completa de cada consulta |

---

## Estrutura do projeto

```
banco-x/
├── .github/
│   └── workflows/
│       └── deploy.yaml          # Pipeline CI/CD
├── app/
│   ├── api/
│   │   ├── main.py              # FastAPI — endpoints /saldo e /health
│   │   ├── requirements.txt
│   │   └── Dockerfile           # Multi-stage build, usuário não-root
│   └── cli/
│       ├── bancox_cli.py        # CLI do funcionário
│       └── setup.sh             # Script de onboarding
├── modules/
│   ├── vpc/                     # VPC, subnets, NAT Gateway
│   ├── alb/                     # Load Balancer + Security Groups
│   ├── ecs/                     # Cluster, services, ECR, IAM
│   └── dynamodb/                # Tabela de contas por ambiente
├── dev/                         # Ambiente de desenvolvimento
├── prod/                        # Ambiente de produção
└── packer/
    └── ami.pkr.hcl              # AMI base com Docker + ECS Agent + SSM
```

---

## Segurança

- **Zero porta 22 aberta** — acesso exclusivo via SSM Session Manager
- **Least privilege** — IAM roles com permissões mínimas por função
- **Secrets Manager** — nenhuma credencial ou URL hardcoded no código
- **Usuário não-root** no container Docker
- **OIDC** no CI/CD — credenciais temporárias, sem Access Keys no repositório
- **Subnets privadas** — ECS inacessível diretamente da internet

---

## CI/CD

Pipeline disparado automaticamente a cada push em `main` com alterações em `app/api/`:

1. Checkout do código
2. Autenticação AWS via OIDC (sem chaves estáticas)
3. Login no ECR
4. Build da imagem com tag `:latest` e `:sha-do-commit`
5. Push para o ECR
6. Force new deployment no ECS Fargate
7. Aguarda estabilização do serviço

---

## Auditoria

Toda consulta de saldo é registrada automaticamente no CloudWatch Logs:

```
2026-05-13 13:54:41,520 - INFO - AUDITORIA | conta=12345-6 | titular=Andre Leao | timestamp=2026-05-13T13:54:41.520306
```

Para gerar relatório de auditoria:

```bash
aws logs filter-log-events \
  --log-group-name "/bancox/dev/api" \
  --filter-pattern "AUDITORIA" \
  --query 'events[*].message' \
  --output text > relatorio_auditoria_$(date +%Y%m%d).txt
```

Para filtrar por conta específica:

```bash
aws logs filter-log-events \
  --log-group-name "/bancox/dev/api" \
  --filter-pattern "\"conta=12345-6\"" \
  --query 'events[*].message' \
  --output table
```

---

## Como usar o CLI

```bash
# Ativar ambiente virtual
source /home/leaos/bancox-cli-env/bin/activate

# Entrar no diretório da aplicação
cd app/cli

# Iniciar o sistema
python3 bancox_cli.py
```

> O CLI busca automaticamente o endpoint da API no Secrets Manager. Nenhuma configuração manual necessária após o deploy.

---

## Deploy da infraestrutura

```bash
# Subir ambiente dev
cd dev
terraform init
terraform apply

# Destruir ambiente dev
terraform destroy
```

> Para instruções detalhadas de operação, troubleshooting e runbook completo, consulte [`bancox_runbook.html`](bancox_runbook.html).

---

## Autor

**André Leão** — DevOps / Cloud Engineer  
GitHub: [LeaoAndre3107](https://github.com/LeaoAndre3107)  
LinkedIn: [linkedin.com/in/andreleao](https://linkedin.com/in/andreleao)
