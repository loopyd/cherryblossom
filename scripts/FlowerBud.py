import time
from GardeningTools import LoginManager
from ClassLogger import ClassLogger

class FlowerBud:
    def __init__(self):
        self.my_logger = ClassLogger(__name__)
        pass

    async def runTask(self, prompt,
            max_length = 32,
            top_k = 0,
            num_beams = 0,
            no_repeat_ngram_size = 2,
            top_p = 0.9,
            seed=42,
            temperature=0.7,
            greedy_decoding = False,
            return_full_text = False):
        
        thread_time = time.time()
        self.my_logger.logger.info("Starting flower bud inference")
        response = None

        try:
            if LoginManager.inferenceHandle == None:
                raise ValueError("Huggingface inference handle object passed was None")

            top_k = None if top_k == 0 else top_k
            do_sample = False if num_beams > 0 else not greedy_decoding
            num_beams = None if (greedy_decoding or num_beams == 0) else num_beams
            no_repeat_ngram_size = None if num_beams is None else no_repeat_ngram_size
            top_p = None if num_beams else top_p
            early_stopping = None if num_beams is None else num_beams > 0

            params = {
                "max_new_tokens": max_length,
                "top_k": top_k,
                "top_p": top_p,
                "temperature": temperature,
                "do_sample": do_sample,
                "seed": seed,
                "early_stopping": early_stopping,
                "no_repeat_ngram_size":no_repeat_ngram_size,
                "num_beams":num_beams,
                "return_full_text":return_full_text
            }
            
            response = LoginManager.inferenceHandle(prompt, params=params)[0]

            proc_time = time.time() - thread_time
            self.my_logger.logger.info(f"Completed flower bud inference")
            self.my_logger.logger.info(f"Processing time was {proc_time} seconds")
        except Exception as e:
            self.my_logger.logger.error(f"Flower bud inference failed with error: {e}")

        return response["generated_text"]