import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CoverageResultsDisplayComponent } from './coverage-results-display.component';

describe('CoverageResultsDisplayComponent', () => {
  let component: CoverageResultsDisplayComponent;
  let fixture: ComponentFixture<CoverageResultsDisplayComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [CoverageResultsDisplayComponent]
    });
    fixture = TestBed.createComponent(CoverageResultsDisplayComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
