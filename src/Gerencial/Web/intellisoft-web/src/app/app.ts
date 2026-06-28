import { Component, signal } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { ClientesComponent } from './clientes/clientes';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, ClientesComponent],
  templateUrl: './app.html',
  styleUrl: './app.scss'
})
export class App {
  protected readonly title = signal('intellisoft-web');
}
