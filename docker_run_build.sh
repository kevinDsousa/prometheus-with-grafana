#!/bin/bash

# Nome dos containers e rede
CONTAINER_GRAFANA="grafana"
CONTAINER_PROMETHEUS="prometheus"
NETWORK_NAME="grafana-network"

# Verifica se a rede grafana-network existe
sudo docker network ls | grep -q "$NETWORK_NAME"
if [ $? -eq 0 ]; then
  echo "A rede '$NETWORK_NAME' já existe."
else
  echo "Erro: A rede '$NETWORK_NAME' não existe. Crie a rede antes de rodar o script."
  exit 1
fi

# Função para parar, remover e recriar os containers
recreate_container() {
  CONTAINER_NAME=$1
  # Verifica se o container está em execução
  sudo docker ps -q -f name="$CONTAINER_NAME" > /dev/null
  if [ $? -eq 0 ]; then
    echo "O container '$CONTAINER_NAME' está em execução. Parando e removendo o container..."
    # Para o container
    sudo docker stop "$CONTAINER_NAME"
    # Remove o container
    sudo docker rm "$CONTAINER_NAME"
  else
    echo "O container '$CONTAINER_NAME' não está em execução."
  fi
  # Cria e sobe o container novamente
  echo "Subindo o container '$CONTAINER_NAME'..."
  sudo docker compose up -d  # Isso garante que o Prometheus e o Grafana sejam conectados à mesma rede
}

# Recriar Grafana e Prometheus
recreate_container "$CONTAINER_GRAFANA"
recreate_container "$CONTAINER_PROMETHEUS"

# Verifica se ambos os containers estão conectados à rede grafana-network
echo "Verificando se os containers estão conectados à rede '$NETWORK_NAME'..."
sudo docker network inspect "$NETWORK_NAME" | grep -q "$CONTAINER_GRAFANA" && echo "$CONTAINER_GRAFANA está conectado à rede $NETWORK_NAME."
sudo docker network inspect "$NETWORK_NAME" | grep -q "$CONTAINER_PROMETHEUS" && echo "$CONTAINER_PROMETHEUS está conectado à rede $NETWORK_NAME."
