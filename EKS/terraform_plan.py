import subprocess
import json
import os
import pandas as pd

def run_command(command):
    """Executa um comando no terminal e trata erros."""
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Erro ao executar: {command}")
        print(result.stderr)
        exit(1)
    return result.stdout

def main():
    # 1. Gera o plano binario do Terraform
    print("Gerando o plano binário do Terraform...")
    run_command("terraform plan -out=tfplan.binary")

    # 2. Converte o arquivo binario para JSON
    print("Convertendo o plano para formato JSON...")
    plan_json_str = run_command("terraform show -json tfplan.binary")

    # 3. Salva o arquivo JSON localmente para auditoria
    json_filename = "tfplan.json"
    with open(json_filename, "w", encoding="utf-8") as f:
        f.write(plan_json_str)
    print(f"Arquivo {json_filename} salvo com sucesso.\n")

    # 4. Faz o parse dos dados com JSON
    plan_data = json.loads(plan_json_str)
    resource_changes = plan_data.get("resource_changes", [])

    if not resource_changes:
        print("Nenhuma alteração de recurso detectada no plano.")
        return

    # 5. Estrutura os dados para a tabela do Pandas
    parsed_resources = []
    for resource in resource_changes:
        address = resource.get("address")
        resource_type = resource.get("type")
        actions = resource.get("change", {}).get("actions", [])
        
        # Junta ações como ["update"] ou ["read"] em formato legível (ex: CREATE, DELETE)
        action_str = ", ".join(actions).upper()

        parsed_resources.append({
            "Endereço do Recurso": address,
            "Tipo": resource_type,
            "Ação": action_str
        })

    # 6. Cria o DataFrame e exibe em formato de tabela limpa
    df = pd.DataFrame(parsed_resources)
    
    print("=" * 80)
    print("                      RESUMO DAS ALTERAÇÕES DO TERRAFORM")
    print("=" * 80)
    print(df.to_string(index=False))
    print("=" * 80)

    # Opcional: Remove os arquivos temporários criados
    # os.remove("tfplan.binary")
    # os.remove("tfplan.json")

if __name__ == "__main__":
    main()