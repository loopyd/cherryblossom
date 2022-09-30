import os, json, asyncio
from huggingface_hub import InferenceApi
from ClassLogger import ClassLogger

class HFLoginManager:
    def __init__(self):
        self._username = None
        self._token = None
        self.inferenceHandle = None
        self.hf_logger = ClassLogger(__name__)
        return
    
    async def getHfToken(self) -> str:
        self.hf_logger.logger.info("Fetching login configuration...")
        result = ""
        js = {}
        filename = os.path.realpath('config.json')
        if not os.path.exists(filename) or not os.path.isfile(filename):
            raise FileNotFoundError("Application config.json not found")
        with open(file=filename, encoding='utf8') as f:
            result = f.read()
            js = json.loads(result)
        self.hf_logger.logger.info("Login configuration fetched successfully")
        self._username = js["username"]
        self._token = js["token"]
        return
    
    async def getInferenceApi(self):
        self.inferenceHandle = InferenceApi("bigscience/bloom",token=self._token)
        return

    def isLoggedIn(self) -> bool: 
        return self.username is not None and self.token is not None

    async def loginTask(self):
        try:
            self.hf_logger.logger.info("Logging into HuggingFace InferenceAPI...")
            tasks = asyncio.gather(
                self.getHfToken(),
                self.getInferenceApi())
            result = await tasks
            self.hf_logger.logger.info("Logged in successfully")
        except Exception as e:
            self.hf_logger.logger.error(f"Login failed with error: {e}")
        return