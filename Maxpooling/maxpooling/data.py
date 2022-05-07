import random
fp = open('data.ram', 'w')

for i in range(100):
    fp.write('%3x ' % (random.randint(0, 256)))
    if i%10 == 9:
        fp.write('\n')

fp.close()