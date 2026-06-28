import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Cliente } from './cliente.model';

@Injectable({
  providedIn: 'root'
})
export class ClienteService {
  private apiUrl = 'http://localhost:9096/clientes';

  constructor(private http: HttpClient) { }

  // Gera o cabeçalho com o Basic Authentication
  private obterCabecalhosAuth(): HttpHeaders {
    const usuario = 'intellisoftGIL';
    const senha = 'G1l2026';

    // A função btoa() converte a string para Base64, padrão exigido pela web
    const credenciaisBase64 = btoa(`${usuario}:${senha}`);

    return new HttpHeaders({
      'Authorization': `Basic ${credenciaisBase64}`,
      'Content-Type': 'application/json'
    });
  }

  listarClientes(): Observable<Cliente[]> {
    return this.http.get<Cliente[]>(this.apiUrl, { headers: this.obterCabecalhosAuth() });
  }

  obterCliente(id: number): Observable<Cliente> {
    return this.http.get<Cliente>(`${this.apiUrl}/${id}`, { headers: this.obterCabecalhosAuth() });
  }

  salvarCliente(cliente: Cliente): Observable<Cliente> {
    return this.http.post<Cliente>(this.apiUrl, cliente, { headers: this.obterCabecalhosAuth() });
  }

  atualizarCliente(id: number, cliente: Cliente): Observable<Cliente> {
    return this.http.put<Cliente>(`${this.apiUrl}/${id}`, cliente, { headers: this.obterCabecalhosAuth() });
  }

  excluirCliente(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`, { headers: this.obterCabecalhosAuth() });
  }
}