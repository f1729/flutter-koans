/// Outside the browser (tests, the VM) events go nowhere.
const enabled = false;

void send(String url, String body) {}

void onPageHide(void Function() callback) {}
