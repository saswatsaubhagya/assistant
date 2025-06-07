# Assistant

A Flutter-based chat assistant app with speech-to-text and n8n integration.

## Getting Started

This project allows you to chat with an AI agent using text or voice, powered by an n8n workflow. Follow the steps below to set up and use the app.

---

## 1. n8n Flow Setup

1. **Import the n8n Flow**
   - Use the provided `chat_bot.json` file to set up your n8n workflow.
   - In your n8n instance, import this JSON to create a basic chat agent flow.

2. **Configure Webhook Security**
   - The webhook node in the flow is set up with basic authentication for security.
   - In n8n, set a username and password for the webhook node to restrict access.

---

## 2. Flutter App Setup

1. **Clone and Install Dependencies**
   - Clone this repository.
   - Run `flutter pub get` to install dependencies.
---

## 3. Using the App

1. **Landing Screen**
   - On first launch, you will be prompted to enter your n8n webhook URL, along with the basic authentication username and password you set up in n8n.

2. **Chatting**
   - Type your message in the chat input and send it. The agent will reply using the n8n workflow.
   - Alternatively, tap the microphone icon to use speech-to-text. Speak your message, and it will be transcribed and sent to the agent.

---

## 4. Resources

- [n8n Documentation](https://docs.n8n.io/)
- [Flutter Documentation](https://docs.flutter.dev/)
- [speech_to_text package](https://pub.dev/packages/speech_to_text)

---

For any issues or contributions, please open an issue or pull request on this repository.
