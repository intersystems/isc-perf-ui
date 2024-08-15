import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CoverageResultDetailComponent } from './coverage-result-detail.component';

describe('CoverageResultDetailComponent', () => {
  let component: CoverageResultDetailComponent;
  let fixture: ComponentFixture<CoverageResultDetailComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [CoverageResultDetailComponent]
    });
    fixture = TestBed.createComponent(CoverageResultDetailComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
