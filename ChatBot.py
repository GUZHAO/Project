from chatterbot import ChatBot

# chatbot = ChatBot(
#     'Ron Obvious',
#     trainer='chatterbot.trainers.ChatterBotCorpusTrainer'
# )

# Train based on the english corpus
#chatbot.train("chatterbot.corpus.english")

# Get a response to an input statement
#chatbot.get_response("Hello, how are you today?")

# -*- coding: utf-8 -*-

# Create a new chat bot named Charlie
chatbot = ChatBot(
    'Charlie',
    trainer='chatterbot.trainers.ListTrainer'
)

chatbot.train([
    "Hi, can I help you?",
    "Sure, I'd like to book a flight to Iceland.",
    "Your flight has been booked."
])

# Get a response to the input text 'How are you?'
response = chatbot.get_response('Are you game')

print(response)