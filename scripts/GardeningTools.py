import logging, logging.handlers, logging.config
from LoginManager import HFLoginManager

LoginManager = HFLoginManager()

def InitRootLogger():
    # Initialize root logger
    rootLogger = logging.getLogger()
    handler = logging.StreamHandler()
    df = logging.Formatter('[{asctime}] {name:16s} {levelname:8s} {message}', style='{')
    handler.setFormatter(df)
    rootLogger.addHandler(handler)
    rootLogger.setLevel(logging.DEBUG)
    return