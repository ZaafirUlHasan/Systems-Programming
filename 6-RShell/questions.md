1. How does the remote client determine when a command's output is fully received from the server, and what techniques can be used to handle partial reads or ensure complete message transmission?

The remote client determines when a command’s output is fully received from the server by checking for the predefined end-of-file (EOF) character (0x04). Since TCP is a stream-based protocol with no inherent message boundaries, the client must explicitly identify when the server has finished sending data. Each time the client calls recv(), it checks if the last byte received matches the EOF character. If it does, the client knows that the server has finished transmitting the response, and it can break out of the receive loop.

To handle partial reads and ensure complete message transmission, the client continuously reads data in a loop until the EOF character is detected. Since recv() does not guarantee that all data will arrive in a single call, the client processes chunks of data as they arrive. Using a fixed-size buffer (rsp_buff), it prints the received portion of the message and continues receiving more data until the entire response is received. This technique ensures robustness against network latency or fragmentation while keeping resource usage efficient.

2. This week's lecture on TCP explains that it is a reliable stream protocol rather than a message-oriented one. Since TCP does not preserve message boundaries, how should a networked shell protocol define and detect the beginning and end of a command sent over a TCP connection? What challenges arise if this is not handled correctly?

The protocol should use a clear delimiter or length-prefixed approach. In my implementation, commands are null-terminated strings (\0), while server responses use an end-of-file (EOF) marker (0x04) to signal the completion of a response. This ensures the client can distinguish when a command ends and when the server has finished sending its output.

If message boundaries are not handled correctly, several issues can arise. Without a delimiter, commands might get concatenated or split unpredictably, leading to incorrect parsing and execution. Partial reads due to network conditions could result in incomplete commands being processed or unintended merging of multiple commands. This can lead to security vulnerabilities, misinterpretation of user input, or deadlocks where the client or server waits indefinitely for data. Proper boundary management prevents these issues and ensures reliable communication between the client and server.

3. Describe the general differences between stateful and stateless protocols.

Stateful and stateless protocols differ in how they track interactions between clients and servers. A stateful protocol maintains information about past interactions, allowing it to remember previous requests and responses. This means that the server keeps track of client-specific details, such as authentication status, active sessions, or previous commands. Some examples of stateful protocols include FTP, SSH, and HTTP with sessions. Stateful protocols enable more complex interactions but require more memory and processing power, and if the server crashes, the session state may be lost.

In contrast, a stateless protocol treats each request as independent, meaning the server does not retain any memory of previous interactions. Each request must contain all necessary information for processing. This simplifies server design, improves scalability, and makes fault recovery easier since no session data is lost. However, more data may be required for each request. Examples include HTTP (without cookies or sessions), UDP, and DNS. Stateless protocols are ideal for high-traffic applications where maintaining a connection state for each client would be inefficient.



4. Our lecture this week stated that UDP is "unreliable". If that is the case, why would we ever use it?

Despite being “unreliable,” UDP is useful in many scenarios where low latency and high performance are more critical than guaranteed delivery. Unlike TCP, UDP does not establish a connection, perform error checking, or ensure ordered delivery, making it significantly faster. This is ideal for applications that can tolerate some packet loss or implement their own reliability mechanisms at the application layer.


5. What interface/abstraction is provided by the operating system to enable applications to use network communications?

The operating system provides the socket API as the primary interface for applications to use network communication. Sockets abstract the complexities of networking, allowing programs to send and receive data over different protocols such as TCP and UDP without needing to manage low-level details like packet construction or routing. This abstraction is typically implemented through system calls like socket(), bind(), listen(), accept(), connect(), send(), and recv() in C.
