import logging
from os import environ,path
from sys import path

sys.path.append(os.path.dirname(os.path.realpath(__file__)))
logging.basicConfig(filename=environ["LOG_NAME"], encoding='utf-8',level=environ["LOG_LEVEL"])
