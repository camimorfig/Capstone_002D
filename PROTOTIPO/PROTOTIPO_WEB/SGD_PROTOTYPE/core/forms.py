from django import forms
from django.contrib.auth.forms import AuthenticationForm


class CustomLoginForm(AuthenticationForm):
    username = forms.EmailField(
        max_length=254,
        widget=forms.EmailInput(attrs={
            'autofocus': True, 
            'class': 'input-custom',
            'placeholder': 'Email'
        })
    )
    password = forms.CharField(
        widget=forms.PasswordInput(attrs={
            'class': 'input-custom',
            'placeholder': 'Password'
        })
    )