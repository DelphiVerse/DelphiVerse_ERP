export interface Cliente {
  id?: number;
  status: boolean;
  nome: string;
  nomeFantasia: string;
  tipoPessoa: 'Física' | 'Jurídica';
  cpf: string;
  rg: string;
  endereco: string;
  numero: string;
  cep: string;
  bairro: string;
  cidade: string;
  uf: string;
  complemento: string;
  observacoes: string;
  email: string;
  telefone: string;
}