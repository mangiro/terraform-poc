import falcon.testing

from src.terraform_poc.app import app


def test_get_quotes():
    client = falcon.testing.TestClient(app)
    resp = client.simulate_get('/quotes')

    assert resp.status_code == 200
    assert resp.json == {
        'quote': 'Talk is cheap. Show me the code.',
        'author': 'Linus Torvalds'
    }
