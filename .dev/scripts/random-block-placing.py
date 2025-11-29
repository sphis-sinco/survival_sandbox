from pynput.keyboard import Key, Controller
import random

keyboard = Controller()

run = False

index = 1

# dirt -
# _
# _
# _
# _
# _
# stone - 

def tab(shift = False):
    index += 1
    if (shift):
        keyboard.press(Key.shift)
    keyboard.press(Key.tab)

while not run:
    with keyboard.press(Key.space):
        run = False

while run:
    keyboard.press(Key.right)
    keyboard.press(Key.enter)
    
    random_integer = random.randint(1, 10)
    if (random_integer == 1):
        tab((index != 1))
        tab((index != 1))
        tab((index != 1))
        tab((index != 1))
        tab((index != 1))
        tab((index != 1))

    with keyboard.press(Key.delete):
        run = False