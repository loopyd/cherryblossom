import logging

class ClassLogger(object):
    def __init__(self, cls_str):
        self.logger = logging.getLogger(cls_str)
        self.logger.parent = logging.root
        self.logger.setLevel(logging.DEBUG)
        pass