#let blocks_data=( // ZSLJTOI
  ((0,2),(1,2),(1,1),(2,1)),
  ((0,1),(1,1),(1,2),(2,2)),
  ((0,1),(1,1),(2,1),(2,2)),
  ((0,1),(1,1),(2,1),(0,2)),
  ((0,1),(1,1),(2,1),(1,2)),
  ((1,1),(2,1),(1,2),(2,2)),
  ((0,2),(1,2),(2,2),(3,2)),
)
#let block_center=((2,1),(2,1),(2,1),(2,1),(2,1),(1.5,1.5),(1.5,1.5))
#let kick_data1=(
  (( 0, 0),(-1, 0),(-1, 1),( 0,-2),(-1,-2)), // 0->R
  (( 0, 0),( 1, 0),( 1,-1),( 0, 2),( 1, 2)), // R->2
  (( 0, 0),( 1, 0),( 1, 1),( 0,-2),( 1,-2)), // 2->L
  (( 0, 0),(-1, 0),(-1,-1),( 0, 2),(-1, 2)), // L->0
  (( 0, 0),( 1, 0),( 1, 1),( 0,-2),( 1,-2)), // 0->L
  (( 0, 0),( 1, 0),( 1,-1),( 0, 2),( 1, 2)), // R->0
  (( 0, 0),(-1, 0),(-1, 1),( 0,-2),(-1,-2)), // 2->R
  (( 0, 0),(-1, 0),(-1,-1),( 0, 2),(-1, 2)), // L->2
)
#let kick_data2=(
  (( 0, 0),(-2, 0),( 1, 0),(-2,-1),( 1, 2)), // 0->R
  (( 0, 0),(-1, 0),( 2, 0),(-1, 2),( 2,-1)), // R->2
  (( 0, 0),( 2, 0),(-1, 0),( 2, 1),(-1,-2)), // 2->L
  (( 0, 0),( 1, 0),(-2, 0),( 1,-2),(-2, 1)), // L->0
  (( 0, 0),(-1, 0),( 2, 0),(-1, 2),( 2,-1)), // 0->L
  (( 0, 0),( 2, 0),(-1, 0),( 2, 1),(-1,-2)), // R->0
  (( 0, 0),( 1, 0),(-2, 0),( 1,-2),(-2, 1)), // 2->R
  (( 0, 0),(-2, 0),( 1, 0),(-2,-1),( 1, 2)), // L->2
)
#let color_data=(rgb("#F44336"),rgb("#4caf50"),rgb("#ff9800"),rgb("#2196f3"),rgb("#9c27b0"),rgb("#ffeb3b"),rgb("#00bcd4"))
#let check(field,hand)={
  for i in range(4){
    let (x,y)=hand.data.at(i)
    x=int(x+hand.x)
    y=int(y+hand.y)
    if x< 0 or x>=10 or y< 0 or y>=20 or field.at(y).at(x)!=0{
      return false
    }
  }
  return true
}
#let turn_left(field,hand)={
  let newhand=hand
  newhand.rot=calc.rem(newhand.rot+3,4)
  let (o1,o2)=block_center.at(hand.id -1)
  for i in range(4){
    let (p1,p2)=hand.data.at(i)
    newhand.data.at(i)=(o1 -(p2 -o2),o2+(p1 -o1))
  }
  for i in range(5){
    let (dx,dy)=kick_data1.at(hand.rot+4).at(i)
    newhand.x=hand.x+dx
    newhand.y=hand.y+dy
    if check(field,newhand){
      return newhand
    }
  }
  return hand
}
#let turn_right(field,hand)={
  let newhand=hand
  newhand.rot=calc.rem(newhand.rot+1,4)
  let (o1,o2)=block_center.at(hand.id -1)
  for i in range(4){
    let (p1,p2)=hand.data.at(i)
    newhand.data.at(i)=(o1+(p2 -o2),o2 -(p1 -o1))
  }
  for i in range(5){
    let (dx,dy)=kick_data1.at(hand.rot).at(i)
    newhand.x=hand.x+dx
    newhand.y=hand.y+dy
    if check(field,newhand){
      return newhand
    }
  }
  return hand
}
#let move_left(field,hand)={
  let newhand=hand
  newhand.x=hand.x -1
  if check(field,newhand){
    return newhand
  }
  return hand
}
#let move_right(field,hand)={
  let newhand=hand
  newhand.x=hand.x+1
  if check(field,newhand){
    return newhand
  }
  return hand
}
#let move_down(field,hand)={
  let newhand=hand
  newhand.y=hand.y -1
  if check(field,newhand){
    return newhand
  }
  return hand
}
#let drop(field,hand)={
  let newhand=hand
  while true{
    newhand.y=hand.y -1
    if check(field,newhand){
      hand=newhand
    }else{
      break
    }
  }
  return hand
}
#let lock(field,hand)={
  for i in range(4){
    let (x,y)=hand.data.at(i)
    x=int(x+hand.x)
    y=int(y+hand.y)
    field.at(y).at(x)=hand.id
  }
  field
}
#let tetris(keys)={
  let hand=(data:none,id:3,rot:0,x:3,y:17)
  let field=range(20).map(_=>(0,0,0,0,0,0,0,0,0,0))
  hand.data=blocks_data.at(hand.id -1)

  // field.at(0)=(1,1,0,0,2,3,4,5,6,7)
  // field.at(19)=(1,2,3,4,5,6,7,0,0,0)

  if "text" in keys.fields(){
    for (i,key) in keys.text.codepoints().enumerate(){
      if key=="a"{
        hand=move_left(field,hand)
      }else if key=="d"{
        hand=move_right(field,hand)
      }else if key=="s"{
        hand=move_down(field,hand)
      }else if key=="w"{
        hand=drop(field,hand)
        field=lock(field,hand)
        hand=(data:none,id:calc.rem(i,7)+1,rot:0,x:3,y:17)
        hand.data=blocks_data.at(hand.id -1)
      }else if key=="j"{
        hand=turn_left(field,hand)
      }else if key=="k"{
        hand=turn_right(field,hand)
      }
    }
  }

  rect(width: 100pt, height: 200pt, inset: 0pt, {
  for i in range(20){
    for j in range(10){
      let block=field.at(i).at(j)
      if block==0{
        continue
      }
      place(top+left, dx:10pt*j, dy:10pt*(19-i), rect(width: 10pt, height: 10pt, fill: color_data.at(block -1)))
    }
  }
  for i in range(4){
    let (x,y)=hand.data.at(i)
    x=x+hand.x
    y=y+hand.y
    place(top+left, dx:10pt*x, dy:10pt*(19-y), rect(width: 10pt, height: 10pt, fill: color_data.at(hand.id -1)))
  }
  })
}

#tetris[]
