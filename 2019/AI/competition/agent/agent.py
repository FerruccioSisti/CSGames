# Modify this function
def start():
    print('start')
    return None


# Modify this function
def play(state):

    index = -1
    indexHero = -1
    indexSpell = -1
    mana = state['player_mana']
    totalDamage = -2
    for x in state['player_target']:
        if x.get('type') == 'hero':
            totalDamage = totalDamage + 2
        else:
            if int(x.get('turns_in_play')) > 0:
                totalDamage += x.get('atk')

    while True:
        if state['opponent_health'] <= totalDamage: #if op can be defeated attack enemy face
            for x in state['player_target']:
                indexHero += 1
                if x.get('type') == 'minion':
                    return (1,(indexHero,0))
                     #hit op's face

        index += 1
        #create a list that contains what is currently playable
        pHand = []
        for x in state['player_hand']:
            if x.get('cost') <= mana:
                pHand.append(x)

        if mana == 0:
            index = -1
            indexHero = -1
            index_source = -1
            indexSpell = -1
            prio(totalDamage, state)
            break;
        elif mana == 1:
            index = -1
            indexHero = -1
            index_source = -1
            indexSpell = -1
            prio(totalDamage, state)
            for x in pHand:
                maxDamage = 0
                health = 0

                if x.get('type') == 'minion':
                    if x.get('id') == 1:
                        return (1, (0, 0))
                    elif x.get('atk') > maxDamage:
                        maxDamage = x.get('atk')
                        health = x.get('health')
                        y = x
                    elif x.get('atk') == maxDamage:

                        if x.get('health') > health:
                            y = x

                    mana = mana - y.get('cost')
                    ##state['player_mana'] = mana

                    return (1,(index,0))

                else:
                    if x.get('id') == 9:
                        mana = mana - x.get('cost')
                        ##state['player_mana'] = mana
                        return (2, (indexSpell, 0))

                    if x.get('id') == 3:
                        mana = mana - x.get('cost')
                        ##state['player_mana'] = mana
                        return (2, (indexSpell, 0))

                    if len(pHand) == 0:
                        if x.get('id') == 2:
                            mana = mana - x.get('cost')
                            ##state['player_mana'] = mana
                            return (2, (indexSpell, 0))

                        if x.get('id') == 12:
                            mana = mana - x.get('cost')
                            ##state['player_mana'] = mana
                            return (2, (indexSpell, 0))


                    if x.get('id') == 13:
                        mana = mana - x.get('cost')
                        ##state['player_mana'] = mana
                        return (2, (indexSpell, 0))



        elif mana == 2:
            index = -1
            indexHero = -1
            index_source = -1
            indexSpell = -1
            prio(totalDamage, state)
            for x in pHand:
                maxDamage = 0
                health = 0

                if x.get('type') == 'minion':
                    if x.get('id') == 1:
                        return 1, (0, 0)
                    elif x.get('atk') > maxDamage:
                        maxDamage = x.get('atk')
                        health = x.get('health')
                        y = x
                    elif x.get('atk') == maxDamage:

                        if x.get('health') > health:
                            y = x

                    mana = mana - y.get('cost')
                    ##state['player_mana'] = mana
                    return (1, (index, 0))

                else:
                    if x.get('id') == 9:
                        mana = mana - x.get('cost')
                        ##state['player_mana'] = mana
                        return 2, (indexSpell, 0)

                    if x.get('id') == 3:
                        mana = mana - x.get('cost')
                        ##state['player_mana'] = mana
                        return 2, (indexSpell, 0)

                    if len(pHand) == 0:
                        if x.get('id') == 2:
                            mana = mana - x.get('cost')
                            ##state['player_mana'] = mana
                            return (2, (indexSpell, 0))

                        if x.get('id') == 12:
                            mana = mana - x.get('cost')
                            ##state['player_mana'] = mana
                            return (2, (indexSpell, 0))


                    if x.get('id') == 13:
                        mana = mana - x.get('cost')
                        ##state['player_mana'] = mana
                        return (2, (indexSpell, 0))



        elif mana == 3:
            index = -1
            indexHero = -1
            index_source = -1
            indexSpell = -1
            prio(totalDamage, state)
            for x in pHand:
                maxDamage = 0
                health = 0

                if x.get('type') == 'minion':
                    if x.get('id') == 1:
                        return 1, (0, 0)
                    elif x.get('atk') > maxDamage:
                        maxDamage = x.get('atk')
                        health = x.get('health')
                        y = x
                    elif x.get('atk') == maxDamage:

                        if x.get('health') > health:
                            y = x

                    mana = mana - y.get('cost')
                    ##state['player_mana'] = mana

                    return (1, (index, 0))

                else:
                    if x.get('id') == 9:
                        mana = mana - x.get('cost')
                        ##state['player_mana'] = mana
                        return 2, (indexSpell, 0)

                    if x.get('id') == 3:
                        mana = mana - x.get('cost')
                        ##state['player_mana'] = mana
                        return 2, (indexSpell, 0)

                    if len(pHand) == 0:
                        if x.get('id') == 2:
                            mana = mana - x.get('cost')
                            ##state['player_mana'] = mana
                            return (2, (indexSpell, 0))

                        if x.get('id') == 12:
                            mana = mana - x.get('cost')
                            ##state['player_mana'] = mana
                            return (2, (indexSpell, 0))


                    if x.get('id') == 13:
                        mana = mana - x.get('cost')
                        ##state['player_mana'] = mana
                        return (2, (indexSpell, 0))

        elif mana == 4:
            index = -1
            indexHero = -1
            index_source = -1
            indexSpell = -1
            prio(totalDamage, state)
            for x in pHand:
                maxDamage = 0
                health = 0

                if x.get('type') == 'minion':
                    if x.get('id') == 1:
                        return 1, (0, 0)
                    elif x.get('atk') > maxDamage:
                        maxDamage = x.get('atk')
                        health = x.get('health')
                        y = x
                    elif x.get('atk') == maxDamage:

                        if x.get('health') > health:
                            y = x

                    mana = mana - y.get('cost')
                    #state['player_mana'] = mana

                    return (1, (index, 0))

                else:
                    if x.get('id') == 9:
                        mana = mana - x.get('cost')
                        #state['player_mana'] = mana
                        return 2, (indexSpell, 0)

                    if x.get('id') == 3:
                        mana = mana - x.get('cost')
                        #state['player_mana'] = mana
                        return 2, (indexSpell, 0)

                    if len(pHand) == 0:
                        if x.get('id') == 2:
                            mana = mana - x.get('cost')
                            #state['player_mana'] = mana
                            return (2, (indexSpell, 0))

                        if x.get('id') == 12:
                            mana = mana - x.get('cost')
                            #state['player_mana'] = mana
                            return (2, (indexSpell, 0))


                    if x.get('id') == 13:
                        mana = mana - x.get('cost')
                        #state['player_mana'] = mana
                        return (2, (indexSpell, 0))

        elif mana == 5:
            index = -1
            indexHero = -1
            index_source = -1
            indexSpell = -1
            prio(totalDamage, state)
            for x in pHand:
                maxDamage = 0
                health = 0

                if x.get('type') == 'minion':
                    if x.get('id') == 1:
                        return 1, (0, 0)
                    elif x.get('atk') > maxDamage:
                        maxDamage = x.get('atk')
                        health = x.get('health')
                        y = x
                    elif x.get('atk') == maxDamage:

                        if x.get('health') > health:
                            y = x

                    mana = mana - y.get('cost')
                    #state['player_mana'] = mana

                    return (1, (index, 0))

                else:
                    if x.get('id') == 9:
                        mana = mana - x.get('cost')
                        #state['player_mana'] = mana
                        return 2, (indexSpell, 0)

                    if x.get('id') == 3:
                        mana = mana - x.get('cost')
                        #state['player_mana'] = mana
                        return 2, (indexSpell, 0)

                    if len(pHand) == 0:
                        if x.get('id') == 2:
                            mana = mana - x.get('cost')
                            #state['player_mana'] = mana
                            return (2, (indexSpell, 0))

                        if x.get('id') == 12:
                            mana = mana - x.get('cost')
                            #state['player_mana'] = mana
                            return (2, (indexSpell, 0))


                    if x.get('id') == 13:
                        mana = mana - x.get('cost')
                        #state['player_mana'] = mana
                        return (2, (indexSpell, 0))

        elif mana == 6:
            index = -1
            indexHero = -1
            index_source = -1
            indexSpell = -1
            prio(totalDamage, state)
            for x in pHand:
                maxDamage = 0
                health = 0

                if x.get('type') == 'minion':
                    if x.get('id') == 1:
                        return 1, (0, 0)
                    elif x.get('atk') > maxDamage:
                        maxDamage = x.get('atk')
                        health = x.get('health')
                        y = x
                    elif x.get('atk') == maxDamage:

                        if x.get('health') > health:
                            y = x

                    mana = mana - y.get('cost')
                    #state['player_mana'] = mana

                    return (1, (index, 0))

                else:
                    if x.get('id') == 9:
                        mana = mana - x.get('cost')
                        #state['player_mana'] = mana
                        return 2, (indexSpell, 0)

                    if x.get('id') == 3:
                        mana = mana - x.get('cost')
                        #state['player_mana'] = mana
                        return 2, (indexSpell, 0)

                    if len(pHand) == 0:
                        if x.get('id') == 2:
                            mana = mana - x.get('cost')
                            #state['player_mana'] = mana
                            return (2, (indexSpell, 0))

                        if x.get('id') == 12:
                            mana = mana - x.get('cost')
                            #state['player_mana'] = mana
                            return (2, (indexSpell, 0))


                    if x.get('id') == 13:
                        mana = mana - x.get('cost')
                        #state['player_mana'] = mana
                        return (2, (indexSpell, 0))

        elif mana == 7:
            index = -1
            indexHero = -1
            index_source = -1
            indexSpell = -1
            prio(totalDamage, state)
            for x in pHand:
                maxDamage = 0
                health = 0

                if x.get('type') == 'minion':
                    if x.get('id') == 1:
                        return 1, (0, 0)
                    elif x.get('atk') > maxDamage:
                        maxDamage = x.get('atk')
                        health = x.get('health')
                        y = x
                    elif x.get('atk') == maxDamage:

                        if x.get('health') > health:
                            y = x

                    mana = mana - y.get('cost')
                    #state['player_mana'] = mana

                    return (1, (index, 0))

                else:
                    if x.get('id') == 9:
                        mana = mana - x.get('cost')
                        #state['player_mana'] = mana
                        return 2, (indexSpell, 0)

                    if x.get('id') == 3:
                        mana = mana - x.get('cost')
                        #state['player_mana'] = mana
                        return 2, (indexSpell, 0)

                    if len(pHand) == 0:
                        if x.get('id') == 2:
                            mana = mana - x.get('cost')
                            #state['player_mana'] = mana
                            return (2, (indexSpell, 0))

                        if x.get('id') == 12:
                            mana = mana - x.get('cost')
                            #state['player_mana'] = mana
                            return (2, (indexSpell, 0))


                    if x.get('id') == 13:
                        mana = mana - x.get('cost')
                        #state['player_mana'] = mana
                        return (2, (indexSpell, 0))

        elif mana == 8:
            index = -1
            indexHero = -1
            index_source = -1
            indexSpell = -1
            prio(totalDamage, state)
            for x in pHand:
                maxDamage = 0
                health = 0

                if x.get('type') == 'minion':
                    if x.get('id') == 1:
                        return 1, (0, 0)
                    elif x.get('atk') > maxDamage:
                        maxDamage = x.get('atk')
                        health = x.get('health')
                        y = x
                    elif x.get('atk') == maxDamage:

                        if x.get('health') > health:
                            y = x

                    mana = mana - y.get('cost')
                    ##state['player_mana'] = mana

                    return (1, (index, 0))

                else:
                    if x.get('id') == 9:
                        mana = mana - x.get('cost')
                        ##state['player_mana'] = mana
                        return 2, (indexSpell, 0)

                    if x.get('id') == 3:
                        mana = mana - x.get('cost')
                        ##state['player_mana'] = mana
                        return 2, (indexSpell, 0)

                    if len(pHand) == 0:
                        if x.get('id') == 2:
                            mana = mana - x.get('cost')
                            ##state['player_mana'] = mana
                            return (2, (indexSpell, 0))

                        if x.get('id') == 12:
                            mana = mana - x.get('cost')
                            ##state['player_mana'] = mana
                            return (2, (indexSpell, 0))


                    if x.get('id') == 13:
                        mana = mana - x.get('cost')
                        #state['player_mana'] = mana
                        return (2, (indexSpell, 0))

        elif mana == 9:
            index = -1
            indexHero = -1
            index_source = -1
            indexSpell = -1
            prio(totalDamage, state)
            for x in pHand:
                maxDamage = 0
                health = 0

                if x.get('type') == 'minion':
                    if x.get('id') == 1:
                        return 1, (0, 0)
                    elif x.get('atk') > maxDamage:
                        maxDamage = x.get('atk')
                        health = x.get('health')
                        y = x
                    elif x.get('atk') == maxDamage:

                        if x.get('health') > health:
                            y = x

                    #mana = mana - y.get('cost')
                    ##state['player_mana'] = mana

                    return (1, (index, 0))

                else:
                    if x.get('id') == 9:
                        mana = mana - x.get('cost')
                        #state['player_mana'] = mana
                        return 2, (indexSpell, 0)

                    if x.get('id') == 3:
                        mana = mana - x.get('cost')
                        #state['player_mana'] = mana
                        return 2, (indexSpell, 0)

                    if len(pHand) == 0:
                        if x.get('id') == 2:
                            mana = mana - x.get('cost')
                            #state['player_mana'] = mana
                            return (2, (indexSpell, 0))

                        if x.get('id') == 12:
                            mana = mana - x.get('cost')
                            #state['player_mana'] = mana
                            return (2, (indexSpell, 0))


                    if x.get('id') == 13:
                        mana = mana - x.get('cost')
                        #state['player_mana'] = mana
                        return (2, (indexSpell, 0))

        elif mana == 10:
            index = -1
            indexHero = -1
            index_source = -1
            indexSpell = -1
            prio(totalDamage, state)
            for x in pHand:
                maxDamage = 0
                health = 0

                if x.get('type') == 'minion':
                    if x.get('id') == 1:
                        return 1, (0, 0)
                    elif x.get('atk') > maxDamage:
                        maxDamage = x.get('atk')
                        health = x.get('health')
                        y = x
                    elif x.get('atk') == maxDamage:

                        if x.get('health') > health:
                            y = x

                    mana = mana - y.get('cost')
                    #state['player_mana'] = mana

                    return (1, (index, 0))

                else:
                    if x.get('id') == 9:
                        mana = mana - x.get('cost')
                        #state['player_mana'] = mana
                        return 2, (indexSpell, 0)

                    if x.get('id') == 3:
                        mana = mana - x.get('cost')
                        #state['player_mana'] = mana
                        return 2, (indexSpell, 0)

                    if len(pHand) == 0:
                        if x.get('id') == 2:
                            mana = mana - x.get('cost')
                            #state['player_mana'] = mana
                            return (2, (indexSpell, 0))

                        if x.get('id') == 12:
                            mana = mana - x.get('cost')
                            #state['player_mana'] = mana
                            return (2, (indexSpell, 0))


                    if x.get('id') == 13:
                        mana = mana - x.get('cost')
                        #state['player_mana'] = mana
                        return (2, (indexSpell, 0))


        if mana >= 2:
            if len(pHand) == 0:
                return 0, (0,0)

        break;

    return 'a', (None,)

def check(enemy):
    if len(enemy) == 0:
        return 1
    else:
        return 0

#Method to use after attacking to decide if use spell or summon minion
def postAtk(mana):

    return None

#creates list priority of enemy to kill
def prio(totalDamage, state):
    index_source = 0
    index_target = 0
    i = 1
    k = 1
    for x in state['player_target']:
        index_source += 1

        if x.get(k != 1):
            print('lul')
        else:
            enemyATK = []
            integerVal = []
            for y in state['opponent_target']:
                if i == 1:
                    highest = 0
                    highestHP = y.get('health')
                    i = 3
                if y.get('health') <= totalDamage:
                    enemyATK.append(y)
                    integerVal.append(index_target)
                    index_target += 1

            #highest = enemyATK[0].get('atk')
            #highestHP = enemyATK[0].get('health')

            highest_index = 0
            index_target = -1
            for y in enemyATK:
                index_target += 1
                if y.get('atk') > highest:
                    highest = y.get('atk')
                    highestHP = y.get('health')
                    returnedEnemy = y
                    highest_index = index_target
                if y.get('atk') == highest:
                    if y.get('health') > highestHP:
                        highest = y.get('atk')
                        highestHP = y.get('health')
                        returnedEnemy = y
                        highest_index = index_target
            if y.get('type') == 'minion':
                return 3, (index_source, highest_index)

        return 4, (0,0)

# Modify this function
def end(victory):
    print(f'Victor: {victory}')
    print('sobayed')
    return None


# Don't touch this function
def communicate(pipe, *args, **kwargs):
    while True:
        packet = pipe.recv()
        action = packet['action']
        if action == 'start':
            pipe.send(start())
        elif action == 'play':
            pipe.send(play(packet['args']))
        elif action == 'end':
            pipe.send(end([packet['args']]))


class CommunicateDebug:
    def __init__(self, *args):
        self.out = None

    def send(self, packet):
        action = packet['action']
        if action == 'start':
            start()
        elif action == 'play':
            self.out = play(packet['args'])
        elif action == 'end':
            end([packet['args']])

    def recv(self):
        return self.out
