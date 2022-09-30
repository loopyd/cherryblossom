import os, time, json, asyncio, sys
import logging, logging.config, logging.handlers, random
from FlowerBud import FlowerBud
import GardeningTools

async def main(*args, **kwargs):
    GardeningTools.InitRootLogger()
    mBloom = FlowerBud()
    task = asyncio.create_task(GardeningTools.LoginManager.loginTask())
    await task
    result = await mBloom.runTask(prompt="I farted and it smells like chicken but", seed=random.randint(- sys.maxsize, sys.maxsize), return_full_text=True, max_length=60)
    print(result)
    return

if __name__=="__main__":
    asyncio.run(main())