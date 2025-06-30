from flask import Flask, jsonify

from main import scrape_yemek_menu


app = Flask(__name__)

@app.route('/yemek-menu', methods=['GET'])
def get_yemek_menu():
    yemek_listesi = scrape_yemek_menu()
    return jsonify(yemek_listesi)

if __name__ == '__main__':
    app.run(debug=True)
