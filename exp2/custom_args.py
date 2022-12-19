from PIL import Image
import numpy as np
import argparse


class ConvertPicture():

    def __init__(self) -> None:
        self.args=None
        self.parse_args()

    def parse_args(self):
        parser = argparse.ArgumentParser(description="convert pic to hex or hex to pic",formatter_class=argparse.RawDescriptionHelpFormatter)
        parser.add_argument("-f","--file",required=True,help="the pic/hex want to convert")
        parser.add_argument("-o","--output",required=False,help="output hexfile or picture")
        parser.add_argument("-s","--size",required=False,help="the size of output picture(axb)")
        self.args=parser.parse_args()

    def pic2hex(self):
        im=Image.open(self.get_arg("file")).convert("L")
        im=np.array(im).astype(np.int16).reshape([-1,1])
        np.savetxt(self.get_arg("output"),im,fmt="%02x")

    def hex2pic(self):
        x,y=self.get_arg("size").split("x")
        d=open(self.get_arg("file")).readlines()
        intd=[int(i.strip("\n"),16) for i in d]
        im = np.asarray(intd).reshape((int(x),int(y)),order="C").astype(np.int8)
        img = Image.fromarray(im,mode="L")
        img.save(self.get_arg("output"))

    def get_arg(self, arg_key: str):
        if hasattr(self.args, arg_key):
            return getattr(self.args, arg_key)
        return None