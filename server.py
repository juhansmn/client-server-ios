import socket
import threading

#Classe genérica de um cliente
class Cliente:
	conexao = None
	endereco =  None

	def __init__(self, conexao, endereco):
		self.conexao = conexao
		self.endereco = endereco

#Localhost
IP = socket.gethostbyname(socket.gethostname())
PORTA = 2350

#Bytes de mensagem
TAMANHO = 64
#Tipo de decodificação
FORMATO = 'utf-8'

#Lista de clientes conectados
clientes = []

def iniciar_servidor():
    #AF_INET: IPv4; SOCK_STREAM: Protocolo TCP
    servidor = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    #Endereço IP que o socket do servidor será referenciado. No caso, uma tupla que recebe o IP e PORTA desejada. 
    servidor.bind((IP, PORTA))

    print(f"[SERVER] {IP} iniciou!")
    
    #Servidor "escuta" apenas duas conexões
    servidor.listen(2)

    while True:
        #Aceita a conexão de um novo cliente e recebe o socket e o respectivo endereço dele.
        conexao, endereco = servidor.accept()
        cliente = Cliente(conexao, endereco)

        print(f"[NOVA CONEXÃO] {cliente.endereco} conectado.")

        clientes.append(cliente)

        thread = threading.Thread(target=resolver_cliente, args=(cliente,))
        thread.start()
        print(f"[CONEXÕES ATIVAS] {len(clientes)}")

#Lida com cada cliente individualmente e de forma simultânea
def resolver_cliente(cliente):
    mensagem_servidor = ''

    #Enquanto o estiver conectado
    while True:
        mensagem_cliente = cliente.conexao.recv(TAMANHO)

        if not mensagem_cliente:
            break
        
        if mensagem_cliente == 'pintar':
            mensagem_servidor = 'imagem_pintada'
            for cliente in clientes:
                cliente.conexao.sendall(mensagem_servidor.encode(FORMATO))

    desconectar_cliente(cliente)

#Desconecta o cliente do servidor
def desconectar_cliente(cliente):
		print(f"[DESCONECTOU] {cliente.endereco} desconectado.")
		cliente.conexao.close()
		clientes.remove(cliente)

if __name__ == '__main__':
	iniciar_servidor()