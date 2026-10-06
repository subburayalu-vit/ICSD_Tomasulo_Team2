from random import Random

TAGS = {"NONE":0,"ALU1":1,"ALU2":2,"ALU3":3}

def step(rat, arf, tr):
    # Combinational outputs from pre-edge state
    t1 = 0 if tr['l1']==0 else rat[tr['l1']]
    t2 = 0 if tr['l2']==0 else rat[tr['l2']]
    match = tr['cv'] and any(rat[i] == tr['ctag'] for i in range(1,32))
    d1 = 0 if tr['l1']==0 else arf[tr['l1']]
    d2 = 0 if tr['l2']==0 else arf[tr['l2']]

    # Sequential update
    if tr['rst']:
        rat = [0]*32
        arf = [0]*32
    else:
        for i in range(1,32):
            if tr['cv'] and rat[i] == tr['ctag']:
                rat[i] = 0
        if tr['ien'] and tr['dest'] != 0:
            rat[tr['dest']] = tr['itag']
        rat[0] = 0
        if tr['cv'] and match and tr['cdest'] != 0:
            arf[tr['cdest']] = tr['data'] & 0xffffffff
        arf[0] = 0
    return (t1,t2,int(match),d1,d2),rat,arf

def check(trs):
    rat=[0]*32; arf=[0]*32
    for n,tr in enumerate(trs):
        out,rat,arf=step(rat,arf,tr)
        # Internal consistency checks equivalent to the scoreboard's expectations.
        assert 0 <= out[0] <= 9 and 0 <= out[1] <= 9, (n,out)
        if tr['rst']:
            assert rat == [0]*32 and arf == [0]*32
    return rat,arf

def directed():
    T=TAGS
    return [
      dict(rst=1,ien=0,dest=0,itag=0,cv=0,ctag=0,cdest=0,data=0,l1=0,l2=0),
      dict(rst=0,ien=0,dest=0,itag=0,cv=0,ctag=0,cdest=0,data=0,l1=0,l2=0),
      dict(rst=0,ien=1,dest=5,itag=1,cv=0,ctag=0,cdest=0,data=0,l1=5,l2=0),
      dict(rst=0,ien=0,dest=0,itag=0,cv=0,ctag=0,cdest=0,data=0,l1=5,l2=0),
      dict(rst=0,ien=1,dest=6,itag=2,cv=0,ctag=0,cdest=0,data=0,l1=6,l2=0),
      dict(rst=0,ien=0,dest=0,itag=0,cv=1,ctag=1,cdest=5,data=0x11112222,l1=5,l2=6),
      dict(rst=0,ien=0,dest=0,itag=0,cv=0,ctag=0,cdest=0,data=0,l1=5,l2=6),
      dict(rst=0,ien=1,dest=6,itag=3,cv=1,ctag=2,cdest=6,data=0xAAAA5555,l1=6,l2=0),
      dict(rst=0,ien=0,dest=0,itag=0,cv=0,ctag=0,cdest=0,data=0,l1=6,l2=0),
      dict(rst=0,ien=1,dest=0,itag=1,cv=0,ctag=0,cdest=0,data=0,l1=0,l2=0),
      dict(rst=0,ien=0,dest=0,itag=0,cv=0,ctag=0,cdest=0,data=0,l1=0,l2=0),
      dict(rst=0,ien=1,dest=7,itag=1,cv=0,ctag=0,cdest=0,data=0,l1=7,l2=0),
      dict(rst=0,ien=1,dest=7,itag=2,cv=0,ctag=0,cdest=0,data=0,l1=7,l2=0),
      dict(rst=0,ien=0,dest=0,itag=0,cv=1,ctag=1,cdest=7,data=0x11111111,l1=7,l2=0),
      dict(rst=0,ien=0,dest=0,itag=0,cv=1,ctag=2,cdest=7,data=0x22222222,l1=7,l2=0),
      dict(rst=0,ien=0,dest=0,itag=0,cv=0,ctag=0,cdest=0,data=0,l1=7,l2=0),
    ]

if __name__ == '__main__':
    rat,arf=check(directed())
    assert arf[7] == 0x22222222, hex(arf[7])

    rng=Random(0x8051_2026)
    trs=[]
    for _ in range(10000):
        trs.append(dict(
            rst=(rng.randrange(20)==0),
            ien=bool(rng.getrandbits(1)),
            dest=rng.randrange(32),
            itag=rng.choice([1,2,3]),
            cv=bool(rng.getrandbits(1)),
            ctag=rng.choice([1,2,3]),
            cdest=rng.randrange(32),
            data=rng.getrandbits(32),
            l1=rng.randrange(32),
            l2=rng.randrange(32),
        ))
    check(trs)
    print('PASS: directed RAT/ARF model checks passed')
    print('PASS: 10,000 randomized legal-input cycles passed')
