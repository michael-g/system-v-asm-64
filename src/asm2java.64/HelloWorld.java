public class HelloWorld {

	static {
		System.loadLibrary("hello");
	}

	public static void main(String[] args) throws Exception {
		HelloWorld hw = new HelloWorld();
		hw.requestGreeting();
	}

	native void requestGreeting();

	void sayHello() {
		System.out.println("Hello, World!");
	}
}

