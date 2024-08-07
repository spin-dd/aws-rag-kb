import os
import json


def set_environ_from_tf(tf_output: str):
    """ terraform output JSONから県境変数を設定する"""
    if not tf_output:
        return 
    for key, value in json.load(open(tf_output)).items():
        os.environ[key] = value["value"]
