from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Hello from Terraform + EC2 + Docker lab!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
