import random
import math

class PillarMode(object):
    def __init__(self):
        self.pm = -1
pm = PillarMode()

class Entity(object):
    def __init__(self, x = 3, y = 3, z = 0, img='background'):
        self.x = x
        self.y = y
        self.z = z
        self.img = img
    
class Pillar(object):
    def __init__(self, x = 0, y = 0):
        self.x = x
        self.y = y
        self.instructions = []
        self.positionsX = [[383, 452, 507, 570], [396,430,504,575], [360,431,489,551]]
        self.positionsY = [[456, 456, 456, 456], [604,604,604,604], [756,756,756,756]]
        
class Henri(object):
    def __init__(self, x = 0, y = 0, entity = 0):
        self.x = x
        self.y = y
        self.instruction = [0]        
        self.ptr = 0
        self.entity = entity
        
    def move(self):
        ins = self.instruction[self.ptr]
        if ins == 0: # random move
            self.x += random.random() - 0.5
            self.y += random.random() - 0.5
                    
            
def setup():
    import random
    import logic
    import entities
    size(1000, 1000)
    global images
    global ents, entsPillar
    global henris
    global pillars
    images = {}
    images['background'] = loadImage("bg.jpg")
    images['henri'] = loadImage("henri.png")
    images['pillar'] = loadImage("pillar.png")
    images['pillarBig'] = loadImage("pillarBig.png")
    for i in range(1,5):
        images['glyphe'+str(i)] = loadImage("glyphe"+str(i)+".png")
    numHenri = 7
    ents = []
    entsPillar = [Entity(0,0,-1,'pillarBig')]
    for i in range(1,5):
        entsPillar.append(Entity(20,20+i*80,0,'glyphe'+str(i)))
    henris = []
    pillars = []

    x = Entity(0,0,-1,'background')
    ents.append(x)
    pillars.append(Pillar(50,50))
    pillars.append(Pillar(random.randint(100, height - 100),random.randint(100, height - 100)))
    pillars.append(Pillar(random.randint(100, height - 100),random.randint(100, height - 100)))
    for p in pillars:
        ents.append(Entity(p.x, p.y ,-1,'pillar'))
        
    for i in range(numHenri):
        henris.append(Henri(random.randint(100, height - 100),random.randint(100, height - 100), len(ents)))
        ents.append(Entity(0,0,1,'henri'))    

def dist(x, y, ps):
    for i, p in enumerate(ps):
        centx = p.x + 134/2
        centy = p.y + 369/2
        if math.sqrt((centx-x)**2 + (centy-y)**2) < 200:
            return i
         
    return -1

def draw():
    background(0)
    # display all entities
    for entity in ents:
        image(images[entity.img], entity.x, entity.y)
        
    if pm.pm >= 0:
        for entity in entsPillar:
            image(images[entity.img], entity.x, entity.y)
            
    for henri in henris:
        henri.move()
        ents[henri.entity].x = henri.x
        ents[henri.entity].y = henri.y
        
def mouseReleased():
    if pm.pm == -1:        
        a = dist(mouseX, mouseY, pillars)
        if a >= 0:
            
            pm.pm = a
    elif pm.pm >= 0:
        if mouseY < 130 and mouseX > 850:
            pm.pm = -1
            
    print pm.pm 


    


