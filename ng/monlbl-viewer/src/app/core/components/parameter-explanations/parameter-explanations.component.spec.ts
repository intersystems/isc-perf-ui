import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ParameterExplanationsComponent } from './parameter-explanations.component';

describe('ParameterExplanationsComponent', () => {
  let component: ParameterExplanationsComponent;
  let fixture: ComponentFixture<ParameterExplanationsComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [ParameterExplanationsComponent]
    });
    fixture = TestBed.createComponent(ParameterExplanationsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
