import json
import pprint

summoning_priority = json.load(open("agent/summoning_priority.json", 'r'))
target_priority = json.load(open("agent/target_priority.json", 'r'))
tired_nibs = []

# Modify this function
def start():
    print('>>> start')

    global summoning_priority, target_priority
    summoning_priority = json.load(open("agent/summoning_priority.json", 'r'))
    target_priority = json.load(open("agent/target_priority.json", 'r'))

    return None


def clapTheBitch(state):
    global tired_nibs
    #pprint(state)
    for pt in state["player_target"]:
        if pt["type"] != "hero" and state["player_target"].index(pt) not in tired_nibs:
            tired_nibs.append(state["player_target"].index(pt))
            return 3, (state["player_target"].index(pt), 0)
        elif pt["type"] == "hero" and state["player_mana"] >= 2 and "hero rest" not in tired_nibs:
            tired_nibs.append("hero rest")
            return 0, (None, None)

    return -1

# Target for spells
def selectAWitch(state, not_player=False):
    nigga_to_pop = -1
    nigga_value = -100000
    for ot in state["opponent_target"]:
        if ot["type"] == "hero":
            if not_player:
                pass
            else:
                n_nigga_value = target_priority[16] + 2
                if n_nigga_value > nigga_value:
                    nigga_value = n_nigga_value
                    nigga_to_pop = state["opponent_target"].index(ot)
        else:
            n_nigga_value = target_priority[ot["id"]]
            n_nigga_value += ot["max_health"] + ot["atk"]
            if n_nigga_value > nigga_value:
                nigga_value = n_nigga_value
                nigga_to_pop = state["opponent_target"].index(ot)

    return nigga_to_pop

# Target for the RNs
def selectABitch(state, r_nig):
    global tired_nibs

    nigga_to_pop = -1
    nigga_value = -100000
    for ot in state["opponent_target"]:
        if ot["type"] == "hero":
            n_nigga_value = target_priority[16] + 2
            if n_nigga_value > nigga_value:
                nigga_value = n_nigga_value
                nigga_to_pop = state["opponent_target"].index(ot)
        else:
            n_nigga_value = target_priority[ot["id"]]
            n_nigga_value += ot["max_health"] + ot["atk"]
            n_nigga_value -= abs(ot["health"] - r_nig["atk"])
            if n_nigga_value > nigga_value:
                nigga_value = n_nigga_value
                nigga_to_pop = state["opponent_target"].index(ot)

    tired_nibs.append(state["player_target"].index(r_nig))

    return 3, (state["player_target"].index(r_nig), nigga_to_pop)

def iActivateMyTrapCard(state):
    card_to_play = -1
    card_value = -100000
    #print("SHOW YOUR HAND")
    #pprint.pprint(state["player_hand"])
    for card in state["player_hand"]:
        if card["cost"] > state["player_mana"]:
            continue

        # Base bias
        n_card_value = 0
        n_card_value += summoning_priority[card["id"]]["base"]
        n_card_value -= summoning_priority[card["id"]]["manaCost"]

        # TODO: Conditional weights

        if n_card_value > card_value:
            card_to_play = state["player_hand"].index(card)

    if card_to_play == -1:
        return -1

    card = state["player_hand"][card_to_play]
    if card["type"] == "minion":
        print(">>> Playing nibba")
        return 1, (card_to_play, None)
    elif card["type"] == "spell":
        print(">>> Playing sorcery")
        if card["id"] == 13:
            return 2, (card_to_play, None)
        else:  # Declare target for spell
            if card["id"] == 2:  # Pick best non player target
                w = selectAWitch(state, True)
                if w == -1:
                    return -1
                else:
                    return 2, (card_to_play, w)
            else:
                w = selectAWitch(state)
                if w == -1:
                    return -1
                else:
                    return 2, (card_to_play, w)

# Modify this function
def play(state):
    global tired_nibs

    print(tired_nibs)
    print("Me:", state["player_health"], "The Fool:", state["opponent_health"])

    # Calculate max damage
    max_dmg = 0
    for pt in state["player_target"]:
        if pt["type"] == "hero":
            max_dmg += 2
        else:
            max_dmg += pt["atk"]

    # One teps
    if max_dmg >= state["opponent_health"]:
        print(">>> Ending this man's whole career")
        clap = clapTheBitch(state)
        if clap != -1:
            return clap

    # Play from hand
    c = iActivateMyTrapCard(state)
    if c != -1:
        return c

    # Declare attackers
    for pt in state["player_target"]:
        #pprint.pprint(pt)
        if pt["type"] == "hero" and state["player_mana"] > 2 and "hero rest" not in tired_nibs:
            tired_nibs.append("hero rest")
            return 0, (None, None)
        elif state["player_target"].index(pt) not in tired_nibs:
            print(">>> Mongering war")
            return selectABitch(state, pt)

    tired_nibs = []
    return 'a', (None,)


# Modify this function
def end(victory):
    print(f'WOKE Victor: {victory}')
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

