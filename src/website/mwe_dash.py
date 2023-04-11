# Run this app with `python app.py` and
# visit http://127.0.0.1:8050/ in your web browser.

import argparse
from typing import Tuple# Create the parser
from dash import Dash, html, dcc
import plotly.express as px
import pandas as pd

def parse_args() -> Tuple[str,bool]:
    # Import the library

    parser = argparse.ArgumentParser()# Add an argument
    parser.add_argument('--port', type=int, required=True)# Parse the argument
    parser.add_argument('--use-https', dest='use_https', action='store_true')# Parse the argument
    args = parser.parse_args()# Print "Hello" + the user input argument
    return args.port, args.use_https

# TODO: support onion domain as host.
dash_host_domain:str="127.0.0.1"
dash_local_port, use_https = parse_args()
app = Dash(__name__)

# assume you have a "long-form" data frame
# see https://plotly.com/python/px-arguments/ for more options
df = pd.DataFrame({
    "Fruit": ["Apples", "Oranges", "Bananas", "Apples", "Oranges", "Bananas"],
    "Amount": [4, 1, 2, 2, 4, 5],
    "City": ["SF", "SF", "SF", "Montreal", "Montreal", "Montreal"]
})

fig = px.bar(df, x="Fruit", y="Amount", color="City", barmode="group")

app.layout = html.Div(children=[
    html.H1(children='Hello Dash'),

    html.Div(children='''
        Dash: A web application framework for your data.
    '''),

    dcc.Graph(
        id='example-graph',
        figure=fig
    )
])

if __name__ == '__main__':
    if use_https:
        # context = ('local.crt','local.key')
        # Use the fullchain certificate and the SSL-certificate private key.
        # (Not the root CA, and definitely not the root CA private key.)
        context = ('fullchain.pem','cert-key.pem')
        app.run_server(host=dash_host_domain, port=dash_local_port, debug=True, ssl_context=context)
    else:
        app.run_server(port=dash_local_port, debug=True)
