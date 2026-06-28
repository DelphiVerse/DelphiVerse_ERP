import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { ClienteService } from './cliente.service';
import { Cliente } from './cliente.model';

@Component({
  selector: 'app-clientes',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './clientes.html',
  styleUrls: ['./clientes.css']
})
export class ClientesComponent implements OnInit {
  clienteForm: FormGroup;
  abaAtiva: 'cadastro' | 'listagem' = 'cadastro';
  clientesList: Cliente[] = [];

  constructor(private fb: FormBuilder, private clienteService: ClienteService) {
    this.clienteForm = this.fb.group({
      id: [{ value: null, disabled: true }],
      status: [true], // true = ativo
      nome: ['', Validators.required],
      nomeFantasia: [''],
      tipoPessoa: ['Física'],
      cpf: [''],
      rg: [''],
      endereco: [''],
      numero: [''],
      cep: [''],
      bairro: [''],
      cidade: [''],
      uf: [''],
      complemento: [''],
      observacoes: [''],
      email: ['', Validators.email],
      telefone: ['']
    });
  }

  ngOnInit(): void {
    this.carregarClientes();
  }

  alternarAba(aba: 'cadastro' | 'listagem'): void {
    this.abaAtiva = aba;
  }

  carregarClientes(): void {
    this.clienteService.listarClientes().subscribe({
      next: (dados) => {
        this.clientesList = dados;
      },
      error: (err) => {
        console.error('Erro ao buscar clientes da API:', err);
      }
    });
  }

  editarCliente(cliente: Cliente): void {
    this.clienteForm.patchValue(cliente);
    this.abaAtiva = 'cadastro'; // Muda para a aba de formulário automaticamente
  }

  gravar(): void {
    if (this.clienteForm.valid) {
      const clienteData: Cliente = this.clienteForm.getRawValue(); // Pega dados incluindo ID
      
      if (clienteData.id) {
        this.clienteService.atualizarCliente(clienteData.id, clienteData).subscribe({
          next: () => alert('Cliente atualizado com sucesso!'),
          error: (err) => console.error('Erro ao atualizar', err)
        });
      } else {
        this.clienteService.salvarCliente(clienteData).subscribe({
          next: (res) => {
            alert('Cliente salvo com sucesso!');
            this.clienteForm.patchValue({ id: res.id });
          },
          error: (err) => console.error('Erro ao salvar', err)
        });
      }
    }
  }

  cancelar(): void {
    this.clienteForm.reset({ status: true, tipoPessoa: 'Física' });
  }

  excluir(): void {
    const id = this.clienteForm.get('id')?.value;
    if (id) {
      this.clienteService.excluirCliente(id).subscribe({
        next: () => {
          alert('Cliente excluído com sucesso!');
          this.cancelar();
        },
        error: (err) => console.error('Erro ao excluir', err)
      });
    } else {
      alert('Nenhum cliente selecionado para exclusão.');
    }
  }

  fechar(): void {
    // Lógica para fechar a tela/modal ou redirecionar
    console.log('Fechando tela...');
  }
}