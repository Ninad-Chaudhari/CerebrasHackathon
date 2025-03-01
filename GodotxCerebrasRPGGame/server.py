from flask import Flask, request, jsonify
from pydantic import BaseModel
import requests
from crewai import Agent, Task, Process
from crewai.tools import tool

app = Flask(__name__)

# Cerebras API Key (Use environment variables in production)
CEREBRAS_API_KEY = ""
CEREBRAS_URL = "https://api.cerebras.net/v1/generate"

def create_npc_agent(npc_data):
    return Agent(
        name=npc_data["name"],
        description=f"A {npc_data['physical_description']} living in {npc_data['location_description']}. Personality: {npc_data['personality']}.",
        llm=dict(provider="cerebras", api_key=CEREBRAS_API_KEY)
    )

def generate_cerebras_response(prompt):
    """Function to send request to Cerebras API and return the response"""
    headers = {
        "Authorization": f"Bearer {CEREBRAS_API_KEY}",
        "Content-Type": "application/json"
    }
    
    payload = {
        "model": "cerebras-gpt",
        "prompt": prompt,
        "max_tokens": 100,
        "temperature": 0.7
    }
    
    response = requests.post(CEREBRAS_URL, json=payload, headers=headers)
    
    if response.status_code == 200:
        return response.json().get("text", "").strip()
    else:
        return "Error generating response"


@app.route("/get_random_action", methods=["POST"])
def get_random_action():
    data = request.get_json()
    npc_data = data.get("npc")

    prompt = (
        f"You are controlling an NPC in a fantasy RPG. "
        f"This NPC is described as: {npc_data['physical_description']}. "
        f"They have a personality that is: {npc_data['personality']}. "
        f"They are currently located at {npc_data['location_description']}. "
        f"Their current health is {npc_data['health']}. "
        f"Decide the NPC's next action. The action should be appropriate to the situation. "
        f"Possible actions: idle, move randomly, talk to another NPC, interact with objects, or attack if in combat. "
        f"Respond with only the action and a brief reason."
    )

    action_response = generate_cerebras_response(prompt)
    
    return jsonify({"npc_action": action_response})

@app.route("/npc_dialogue", methods=["POST"])
def npc_dialogue():
    data = request.get_json()
    print("DATA : ",data)
    npc_data = data.get("npc")
    player_message = data.get("player_message")
    
    npc_agent = create_npc_agent(npc_data)
    
    # Define task
    task = Task(
        description=f"Respond to the player while subtly hinting at secret knowledge: {npc_data['secret_knowledge']}",
        agent=npc_agent,
        inputs={"message": player_message}
    )
    
    # Run Process
    process = Process(tasks=[task])
    response = process.run()
    
    return response

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)

