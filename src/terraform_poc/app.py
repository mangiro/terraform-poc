import json
import falcon
from gunicorn.app.base import BaseApplication


class Resource:

    def on_get(self, req, resp):
        quote = {
            'quote': 'Talk is cheap. Show me the code.',
            'author': 'Linus Torvalds'
        }

        resp.text = json.dumps(quote, ensure_ascii=False)
        resp.status = falcon.HTTP_200


app = application = falcon.App()

quotes = Resource()
app.add_route('/quotes', quotes)


class StandaloneApplication(BaseApplication):

    def __init__(self, app, options=None):
        self.options = options or {}
        self.application = app
        super().__init__()


    def load_config(self):
        config = {key: value for key, value in self.options.items() \
            if key in self.cfg.settings and value is not None}

        for key, value in config.items():
            self.cfg.set(key.lower(), value)


    def load(self):
        return self.application


def main():
    StandaloneApplication(app).run()


if __name__ == '__main__':
    main()
