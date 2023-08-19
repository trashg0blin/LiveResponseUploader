import logging
from os import environ
import os, sys; sys.path.append(os.path.dirname(os.path.realpath(__file__)))



logging.basicConfig(filename=environ["LOG_NAME"], encoding='utf-8',level=environ["LOG_LEVEL"])
