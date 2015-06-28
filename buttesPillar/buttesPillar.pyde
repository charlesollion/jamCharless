x = 3
import logic

def setup():
    size(1000, 1000)
    global img
    img = loadImage("pourri.jpg")

def draw():
    background(0)
    fill(0)
    
    if  mousePressed:
        fill(0)        
        image(img, mouseX, mouseY)
    else:
        fill(255)
    #ellipse(mouseX, mouseY, 80, 80)
    
    
    
a = ["charlesB", "charlesO"]
import random
print random.choice(a) + " est le plus fort"



