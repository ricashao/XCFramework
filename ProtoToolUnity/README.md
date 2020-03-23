自动生成通信代码Msg和Service代码  
## Service中，用于手写代码的标注
### $area1 class上方的手写代码
```java
/*-*begin $area1*-*/
// 这里用于手写在class上方的代码
/*-*end $area1*-*/

class XXX{
}
```

### $onRegister class上方的手写代码
```java
class XXX{
    onRegister() {
        super.onRegister();
	    //...
	    //自动生成的代码
	    //...
	
        /*-*begin $onRegister*-*/
        // 这里用于手写在class上方的代码
        /*-*end $onRegister*-*/
    }
}
```

### $area2 class里面的手写代码
```java
class XXX{
//...
//自动生成的代码
//...

/*-*begin $area2*-*/
// 这里用于手写在class上方的代码
/*-*end $area2*-*/

}
```

### $area3 class里面的手写代码
```java
class XXX{
//...
//自动生成的代码
//...

}

/*-*begin $area3*-*/
// 这里用于手写在class上方的代码
/*-*end $area3*-*/
```

### recieve方法体中的手写代码
```java
protected handler(data: NetData) {
		let msg: XXX = <XXX>data.data;
		/*-*begin handler*-*/
		//这里是手写代码
		/*-*end handler*-*/
	}
```