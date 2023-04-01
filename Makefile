include .env
export

run:
	go run ./cmd/main.go

# ngrok
PUBLIC_URL := $(shell curl -s localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url')

ngrok-install:
	curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
	| sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null \
	&& echo "deb https://ngrok-agent.s3.amazonaws.com buster main" \
	| sudo tee /etc/apt/sources.list.d/ngrok.list \
	&& sudo apt update && sudo apt install ngrok

ngrok-config:
	ngrok config add-authtoken ${NGROK_TOKEN}

ngrok-expose:
	ngrok http ${PORT}

# telegram
TELEGRAM_URL := "https://api.telegram.org/bot${TELEGRAM_TOKEN}"

telegram-webhook:
	curl -F "url=${PUBLIC_URL}" "${TELEGRAM_URL}/setWebhook"


# OpenAI
openai-models:
	curl -G https://api.openai.com/v1/models \
    -H "Authorization: Bearer ${OPENAI_TOKEN}" \
    -H "Content-Type: application/json"

openai-usage:
	curl -G https://api.openai.com/v1/usage \
         -H "Authorization: Bearer ${OPENAI_TOKEN}" \
         --data-urlencode "date=$(date +%Y-%m-%d)"

openai-completions:
	curl https://api.openai.com/v1/chat/completions \
	  -H "Content-Type: application/json" \
	  -H "Authorization: Bearer  ${OPENAI_TOKEN}" \
	  -d '{ "model": "gpt-3.5-turbo", "messages": [{"role": "system", "content": "You are a helpful tutor who can help me improve my English. You are kindly fix my errors if there is any and teach some grammar if needed."}, {"role":"user", "content": "Analyze my English: You are a helpful tutor that help me improve English"}] }' \
	  | jq -r '.choices[0].message.content'