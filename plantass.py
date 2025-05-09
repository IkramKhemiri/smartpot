import speech_recognition as sr
from gtts import gTTS
import os
import time
import pygame
from io import BytesIO
import requests
import random
class SmartPlantPotAssistant:
    def __init__(self, model_name="llama3"):
        self.recognizer = sr.Recognizer()
        self.recognizer.pause_threshold = 1.5
        self.recognizer.energy_threshold = 4000
        self.microphone = sr.Microphone()
        self.model_name = model_name

        pygame.mixer.init()

        self.user_mood = "neutral"
        self.conversation_history = []

        # Nouvelle instruction système
        self.system_prompt = """You are "GreenCompanion", a smart gardening assistant for elderly users.
You live inside a smart plant pot that talks with the user.
Your goals:
1. Give gardening advice clearly and warmly.
2. Respond to voice commands like watering or checking plant health.
3. Remind users to take care of the plant with gentle encouragement.
4. Use simple words and short sentences.
5. Be kind, supportive, and patient.
You may also give random gardening tips when the user is silent.
"""

        self.conversation = [
            {"role": "system", "content": self.system_prompt},
            {"role": "assistant", "content": self.get_welcome_message()}
        ]

        self.speak(self.conversation[-1]["content"])

    def get_welcome_message(self):
        return "Hello! I'm your smart plant pot. I'm happy to grow with you. How is your day going?"

    def speak(self, text):
        print(f"Assistant: {text}")
        tts = gTTS(text=text, lang='en', slow=True)
        fp = BytesIO()
        tts.write_to_fp(fp)
        fp.seek(0)

        pygame.mixer.music.load(fp)
        pygame.mixer.music.play()
        while pygame.mixer.music.get_busy():
            time.sleep(0.1)

    def listen(self):
        with self.microphone as source:
            print("[Listening for your gardening question...]")
            try:
                audio = self.recognizer.listen(source, timeout=10, phrase_time_limit=15)
                text = self.recognizer.recognize_google(audio)
                print(f"You: {text}")
                return text
            except sr.WaitTimeoutError:
                return ""
            except sr.UnknownValueError:
                self.speak("I'm sorry, could you repeat that?")
                return ""
            except sr.RequestError:
                self.speak("The listening service is not available now.")
                return ""

    def generate_response(self, user_input):
        if not user_input:
            return random.choice([
                "Did you know? Most plants like to be watered in the morning.",
                "Tip: Don't forget to rotate your pot so the plant gets even sunlight.",
                "Your plant loves gentle care and attention. Just like us!"
            ])

        self.conversation.append({"role": "user", "content": user_input})

        data = {
            "model": self.model_name,
            "messages": self.conversation,
            "stream": False,
            "options": {
                "temperature": 0.5,
                "repeat_penalty": 1.1
            }
        }

        try:
            response = requests.post("http://localhost:11434/api/chat", json=data)
            if response.status_code == 200:
                result = response.json()
                response_text = result['message']['content']
                self.conversation.append({"role": "assistant", "content": response_text})
                return response_text
            else:
                return self.get_fallback_response()
        except Exception as e:
            print(f"Error: {e}")
            return self.get_fallback_response()

    def get_fallback_response(self):
        return random.choice([
            "Let’s try that again.",
            "I’m not sure I understood. Could you say it differently?",
            "Hmmm, that’s a tricky one. Try asking in another way!"
        ])

    def run(self):
        try:
            while True:
                user_input = self.listen()

                if user_input:
                    if any(word in user_input.lower() for word in ["bye", "exit", "stop"]):
                        self.speak("It was lovely talking with you. Take care of our little plant!")
                        break
                    response = self.generate_response(user_input)
                    self.speak(response)
                else:
                    idle_tip = self.generate_response("")
                    self.speak(idle_tip)

        except KeyboardInterrupt:
            self.speak("Goodbye! Keep the plant happy!")

if __name__ == "__main__":
    assistant = SmartPlantPotAssistant(model_name="llama3")
    assistant.run()
