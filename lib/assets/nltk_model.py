# All credits to Timothy W. https://github.com/weetimo
import random
import time
import string

print("Finish setup")

def categoriser():
    categories = ['Tank', 'Artillery', 'UAV', 'Fighter Aircraft', 'Helicopter', 'Missile', 'MANPAD', 'Infrastructure']
    return random.choice(categories)

def tagger():
    tags_dict = {}
    for i in range(5):
        key = random.choice(string.ascii_lowercase)
        val = random.randint(0, 100)
        tags_dict[key] = val
    return tags_dict

def summariser():
    return "This is a valid summary with more than 10 words and less than 100 words"

def nltk_model(request):
    request_json = request.get_json()
    request_args = request.args
    response = {}

    if request_json and 'upload_text' in request_json:
        upload_text = request_json['upload_text']
        # Run model
        tags_dict = tagger()
        summary = summariser()
        category = categoriser()
        response = {"summary": summary, "tags": tags_dict, "category": category}
    return response
