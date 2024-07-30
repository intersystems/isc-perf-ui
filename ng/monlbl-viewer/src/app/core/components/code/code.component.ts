import { Component, Input, OnInit } from '@angular/core';
import { Subject } from 'rxjs';
import { CodeService } from '../../services/code.service';

@Component({
  selector: 'app-code',
  templateUrl: './code.component.html',
  styleUrls: ['./code.component.scss']
})
export class CodeComponent {
  code: Subject<any> = new Subject();

  private lastResult = {
    results: []
  };
  sort: string = "";

  @Input() metrics: string[] = ["RtnLine","Time","TotalTime"];

  constructor(private codeService: CodeService) {
    this.codeService.getCurrentResults().subscribe(results => {
      this.lastResult = results;
      if (results.results && results.results[0] && results.results[0].metrics) {
        this.metrics = Object.keys(results.results[0].metrics);
      }
      this.applySort();
    });
  }

  computeGridStyle(): string {
    return `grid-template-columns: repeat(${this.metrics.length}, 90px) auto;`
  }

  toggleSort(metric: string) {
    if (this.sort === metric) {
      this.sort = "";
    } else {
      this.sort = metric;
    }
    this.applySort();
  }

  applySort(): void {
    if ((this.lastResult === undefined) || (!this.lastResult.results) || (this.sort === "")) {
      this.code.next(this.lastResult);
      return;
    }
    this.code.next({
      results: [...this.lastResult.results].sort((first: any, second: any) => {
        return second.metrics[this.sort] - first.metrics[this.sort];
      })
    });
  }

  viewInContext(lineNumber: number): void {
    let behavior: "auto" | "smooth" = "auto";
    if (this.sort == "") {
      behavior = "smooth";
    } else {
      this.sort = "";
      this.applySort();
    }

    // Scroll to line in context on next click.
    setTimeout(() => {
      const prevLine = (lineNumber < 11) ? 1 : lineNumber - 10;
      const el = document.getElementById("line" + lineNumber);
      if (el) {
        document.getElementById("line" + prevLine)?.scrollIntoView({behavior});
        if (el.style.backgroundColor == 'rgb(255, 255, 0)') {
          el.style.backgroundColor = '';
        } else {
          el.style.backgroundColor = 'rgb(255, 255, 0)';
        }
      }
    },0);
  }
}
