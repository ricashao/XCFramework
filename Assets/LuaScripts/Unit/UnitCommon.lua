--骑乘状态
MountType = {
    ground = 0,
    ride = 1,
}

--动作类型 要和ts对应
ActionType = {
    --待机
    standBy = 0,
    --移动
    move = 1,
    --攻击
    attack = 2,
    --施法
    cast = 3,
    --受伤
    hurt = 4
}

-- 数量和acitontype对应
ActionAim = {
    "a",
    "b",
    "c",
    "d",
    "e"
}

--人物容器转向时候，对应的scaleX
FaceScaleX = {
    --[[↘]]1,
    --[[↗]]1,
    --[[↖]]-1,
    --[[↙]]-1,
}

FaceDirection = {
    --[[↘]]0,
    --[[↗]]1,
    --[[↖]]1,
    --[[↙]]0,
}


